# Operation

## Overview

This repository serves as the main entry point for the **Sentiment Analysis System for Restaurant Reviews**. It includes a Docker Compose configuration to streamline deployment and simplify operational management.

### Related Repositories

* **Model Training**: [github.com/remla25-team7/model-training](https://github.com/remla25-team7/model-training)
* **Model Service**: [github.com/remla25-team7/model-service](https://github.com/remla25-team7/model-service)
* **Library for Machine Learning (lib-ml)**: [github.com/remla25-team7/lib-ml](https://github.com/remla25-team7/lib-ml)
* **Library for Versioning (lib-version)**: [github.com/remla25-team7/lib-version](https://github.com/remla25-team7/lib-version)
* **Application Frontend and Service (app)**: [github.com/remla25-team7/app](https://github.com/remla25-team7/app)

---

## Prerequisites

* [Docker & Docker Compose](https://docs.docker.com/compose/install/)
* [Vagrant](https://developer.hashicorp.com/vagrant/install)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm](https://helm.sh/docs/intro/install/)

### Preparation

1. **Clone the repository** and move into the root directory:

   ```bash
   git clone https://github.com/remla25-team7/deployment.git
   cd deployment
   ```

2. **Create the `secrets` folder** (if it doesn't exist):

   ```bash
   mkdir -p secrets
   ```

3. **Define the API key for the Model Service**:

   ```bash
   echo "API_KEY=your_actual_key_here" > secrets/model_credentials.txt
   ```

---

## Running the App with Docker Compose

### Setup

* `docker-compose.yml` defines two services:

  * `app`: The **only** service exposed to the host (port `5001`)
  * `model-service`: Internal backend service (accessible only within Docker network)
* Environment configuration is stored in `.env`
* Docker **secrets** are used to pass the API key to both services
* Volumes:

  * `model-cache`: Caches the downloaded ML model/vectorizer
  * `app-logs`: Stores logs from the app service

### To start the full application stack:

```bash
docker compose up
```

By default, this pulls the **latest released versions** of the services:

```env
APP_SERVICE=latest
MODEL_SERVICE_VERSION=latest
```

To run a version with the **confidence score per prediction feature**, comment out the `latest` versions and **uncomment** the following in `.env`:

```env
# APP_SERVICE=v0.1.0
# MODEL_SERVICE_VERSION=0.3.0
```

### Access the App

Once running, visit:

* **Frontend UI**: [http://localhost:5001/](http://localhost:5001/)
* **Swagger UI (API Docs)**: [http://localhost:5001/apidocs/](http://localhost:5001/apidocs/)

### Stopping the App

To stop the app but **preserve model cache and logs**:

```bash
docker compose down
```

To stop and **fully remove all data** (including downloaded models and logs):

```bash
docker compose down --volumes
```

---

## Running the App on Kubernetes

### Cluster Provisioning

To provision the full Kubernetes cluster (controller + worker nodes), verify the setup, and expose the Kubernetes Dashboard:

1. **Make the script executable (only needed once):**

   ```bash
   chmod +x provision-and-verify.sh
   ```

2. **Run the provisioning and verification script:**

   ```bash
   ./provision-and-verify.sh
   ```

This script will:

* Bring up all Vagrant VMs (`ctrl`, `node-1`, `node-2`)
* Run Ansible provisioning on all machines
* Wait for all nodes to become `Ready`
* Automatically configure your local `/etc/hosts` file so you can access the dashboard
* Apply the `finalization.yml` playbook to install:

  * MetalLB
  * NGINX Ingress Controller
  * Kubernetes Dashboard
  * Istio
* Verify the health of all installed components (MetalLB, Ingress, Istio, Dashboard)

> **During provisioning**, you may be prompted for your **sudo password** so that the script can automatically update your `/etc/hosts` with the NGINX Ingress IP and hostnames (e.g., `dashboard.local`).

> **After the script completes**, it will print:
>
> ```bash
> export KUBECONFIG=$(pwd)/kubeconfig
> ```
>
> Make sure to **copy and run** that command in your terminal so you can interact with your new cluster via `kubectl`.

### Accessing the Kubernetes Dashboard

Once the script finishes:

1. Visit [https://dashboard.local](https://dashboard.local) in your browser.

2. To log in, generate a token:

   ```bash
   kubectl -n kubernetes-dashboard create token admin-user
   ```

3. Paste the token into the login screen of the dashboard.

> Tip: If the browser complains about a self-signed certificate, choose to "Proceed Anyway" (HTTPS is enabled via NGINX Ingress).

---

## Deploying with Helm

We provide a Helm chart in `helm/restaurant-sentiment` for deploying the application on Kubernetes.

### Basic Installation

By default, the chart uses the NGINX Ingress Controller for external traffic:

```bash
helm install restaurant-sentiment ./helm/restaurant-sentiment
```

This will deploy:

* App and Model Service
* ClusterIP Services
* Ingress resources pointing at `app.local` and `model.local`
* Monitoring (Prometheus & Grafana) if enabled

#### Adding Hostnames

After installation, add the following entries to your `/etc/hosts` (replace `<INGRESS_IP>` with your NGINX Ingress IP):

```
<INGRESS_IP> app.local model.local prometheus.local grafana.local
```

You can now access:

* App: [http://app.local](http://app.local)
* Model API: [http://model.local/predict](http://model.local/predict)
* Prometheus: [http://prometheus.local](http://prometheus.local)
* Grafana: [http://grafana.local](http://grafana.local)

### Custom Values

To override default images or ports:

```bash
helm install restaurant-sentiment ./helm/restaurant-sentiment \
  --set app.image=ghcr.io/remla25-team7/app:v1.0.0 \
  --set modelService.image=ghcr.io/remla25-team7/model-service:v1.0.0
```

<!-- space for Prometheus & Grafana operation instructions -->

---

## Traffic Management & Rate Limiting

### Traffic Management with Istio

To enable Istio-based traffic splitting between two versions of the app, run:

```bash
helm upgrade restaurant-sentiment ./helm/restaurant-sentiment \
  --set trafficManagement.enabled=true
```

This switches traffic handling from NGINX Ingress to the Istio Ingress Gateway and:

* Deploys two app Deployments (v1 & v2) and two model-service Deployments (v1 & v2)
* Creates Istio `Gateway`, `DestinationRule`, and `VirtualService` resources
* Splits HTTP traffic 60/40 between v1 and v2 of the app
* Routes each app version to its corresponding model-service version

Traffic is exposed at [http://192.168.56.90](http://192.168.56.90) by default (adjust in `/etc/hosts`).

You can visualize the traffic flow in Kiali:

```bash
# on the control-plane VM:
istioctl dashboard kiali --address 0.0.0.0
```

Then visit [http://192.168.56.100:20001/kiali/console](http://192.168.56.100:20001/kiali/console) to see live splits.

### Rate Limiting with Envoy

To enforce per-user rate limiting (10 requests/minute) via Envoy:

```bash
helm upgrade restaurant-sentiment ./helm/restaurant-sentiment \
  --reuse-values \
  --set rateLimiting.enabled=true \
  --set trafficManagement.enabled=true
```

This adds:

* A global Envoy rate-limit filter at the Istio Ingress Gateway
* A reference rate-limit service (gRPC + Redis)
* A ConfigMap (`ratelimit-config`) defining the `X-USER-ID` descriptor

#### Testing Rate Limits

Run:

```bash
for i in {1..15}; do \
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST \
    -H "x-user-id: test-user-123" \
    -H "Content-Type: application/json" \
    --data '{"review":"The food was great!"}' \
    http://192.168.56.90/predict; \
  sleep 1; \
  done
```

* **200** for the first 10 requests
* **429** for requests 11–15

This ensures individual users can’t overload the service.

---

# Uninstallation

```bash
helm uninstall restaurant-sentiment
```

# Troubleshooting

See logs and resources:

```bash
kubectl get pods,svc,ingress -l app.kubernetes.io/instance=restaurant-sentiment
kubectl logs -l app.kubernetes.io/component=app
kubectl logs -l app.kubernetes.io/component=model
```

---


-------

### Deploying the Application with Helm

#### 1. Install Prometheus Monitoring Stack

To install the Prometheus kube-prometheus-stack chart from the `prometheus-community` repository, run:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --set prometheus.prometheusSpec.maximumStartupDurationSeconds=300
```

#### 2. Navigate to the Helm Chart Directory

```bash
cd helm/restaurant-sentiment
```

#### 3. Install the Application Helm Chart

```bash
helm install sentiment .
```

#### 4. Verify Deployment and Port-Forward the App Service

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl port-forward svc/sentiment-app 5001:5001
```

- **App-service**: [http://localhost:5001](http://localhost:5001)
- **App-service metrics**: [http://localhost:5001/metrics](http://localhost:5001/metrics)

---

### Monitoring and Observability

#### Access Prometheus UI

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

- **Prometheus UI**: [http://localhost:9090](http://localhost:9090)

#### Enable Email Alerts

1. Edit `values.yaml` and set your email and SMTP details under `.Values.alertmanager.email`.
2. If using Gmail with 2FA, create an [App Password](https://support.google.com/accounts/answer/185833?hl=en).
3. Create the SMTP password secret and restart Alertmanager:

   ```bash
   kubectl create secret generic kube-prometheus-stack-alertmanager-secret --from-literal=smtpPassword='your-app-password' -n monitoring
   kubectl delete pod alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring
   cd helm/restaurant-sentiment && helm upgrade sentiment .
   ```

#### Test Alerts

Generate traffic to trigger alerts:

```bash
while true; do curl -s http://localhost:5001/ > /dev/null; done
```

#### Debugging

If you update your app image or Helm chart and want to redeploy:

```bash
kubectl rollout restart deployment app
cd helm/restaurant-sentiment
helm upgrade sentiment .
```

---

### Accessing Grafana Dashboard

To start Grafana Dashboard:

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

- **Grafana Dashboard**: [http://localhost:3000](http://localhost:3000)
- **Admin login**:
  - Username: Admin
  - Password: prom-operator

The dashboard should be visible under the name "Restaurant Sentiment Dashboard".

If a new image is pulled and you want to rerun Grafana, run:

```bash
kubectl rollout restart deployment prometheus-grafana -n monitoring
```

