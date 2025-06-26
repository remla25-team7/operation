# Operation

## Overview

This repository serves as the main entry point for the **Sentiment Analysis System for Restaurant Reviews**. It includes a Docker Compose configuration to streamline deployment and simplify operational management.

### Related Repositories

- **Model Training**: [github.com/remla25-team7/model-training](https://github.com/remla25-team7/model-training)
- **Model Service**: [github.com/remla25-team7/model-service](https://github.com/remla25-team7/model-service)
- **Library for Machine Learning (lib-ml)**: [github.com/remla25-team7/lib-ml](https://github.com/remla25-team7/lib-ml)
- **Library for Versioning (lib-version)**: [github.com/remla25-team7/lib-version](https://github.com/remla25-team7/lib-version)
- **Application Frontend and Service (app)**: [github.com/remla25-team7/app](https://github.com/remla25-team7/app)

---

## Prerequisites

- [Docker & Docker Compose](https://docs.docker.com/compose/install/)
- [Vagrant](https://developer.hashicorp.com/vagrant/install)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

### 🔧 Preparation

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

- `docker-compose.yml` defines two services:
  - `app`: The **only** service exposed to the host (port `5001`)
  - `model-service`: Internal backend service (accessible only within Docker network)
- Environment configuration is stored in `.env`
- Docker **secrets** are used to pass the API key to both services
- Volumes:
  - `model-cache`: Caches the downloaded ML model/vectorizer
  - `app-logs`: Stores logs from the app service

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

- **Frontend UI**: [http://localhost:5001/](http://localhost:5001/)
- **Swagger UI (API Docs)**: [http://localhost:5001/apidocs/](http://localhost:5001/apidocs/)

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

- Bring up all Vagrant VMs (`ctrl`, `node-1`, `node-2`)
- Run Ansible provisioning on all machines
- Wait for all nodes to become `Ready`
- Automatically configure your local `/etc/hosts` file so you can access the dashboard
- Apply the `finalization.yml` playbook to install:
  - MetalLB
  - NGINX Ingress Controller
  - Kubernetes Dashboard
  - Istio
- Verify the health of all installed components (MetalLB, Ingress, Istio, Dashboard)

During execution, you will see:

- Status of each Vagrant VM
- Ansible logs for each provisioner and playbook
- Final verification of all services
- Success messages with further instructions

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

## Assignment Progress Log (OLD README)

### Assignment A1

- **Model-Training**

  - Created the ML training pipeline using a Hugging Face model.

- **Model-Service**

  - Containerized the ML model with Docker and exposed it via a Flask REST API.
  - Implemented a GitHub Actions workflow to automatically build and publish the container.

- **Lib-ML**

  - Standardized preprocessing in a PyPI package used by both training and the model service.

- **Lib-Version**

  - Built a version-checker utility for the app service.

- **App**

  - Developed a Dockerized web application using HTML/Bootstrap 5 (frontend) and Flask (backend).

- **Operation**

  - Centralized deployment configurations in this repository, featuring Docker Compose and detailed README instructions.

### Assignment A2

#### Prerequisites

- **Vagrant** & **VirtualBox** installed
- **Ansible 2.18+** on host (or use the bundled Vagrant provisioner)
- Host OS user must be able to edit `/etc/hosts`

#### 1. Clone & Spin Up

```bash
git clone <repo-url> && cd <repo-dir>

echo "192.168.56.95 dashboard.local" | sudo tee -a /etc/hosts
vagrant up
vagrant provision
```

#### 2. Load kubeconfig to all your terminal sessions

Depending on what terminal you are using:
if you are using zsh or

```bash
nano ~/.zshrc
```

or if you are using bash.

```bash
nano ~/.bashrc
```

Copy the full path of the file named kubeconfig in this repository.
Then paste this line at the end of your .bashrc/.zshrc:

```bash
export KUBECONFIG=path/to/your/operation/kubeconfig
```

#### 3. Obtain access token

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

##### 3.1 Kubernetes Dashboard port-forwarding

If for some reason you cannot access the dashboard by following the above steps, you can port-foward it, but we recommend setting up the direct access.

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

Kubernetes can be accessed through http://localhost:8443

### Assignment 3

### 1. Installing Prometheus with Helm

To install the Prometheus kube-prometheus-stack chart from the `prometheus-community` repository, run the following command:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace --set prometheus.prometheusSpec.maximumStartupDurationSeconds=300
```

### 2. Navigate to the Helm Chart Directory

```bash
cd helm/restaurant-sentiment
```

### 3. Install the Helm Chart

```bash
helm install sentiment .
```

### 4. Check that it Works and port-forward the app-service

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl port-forward svc/sentiment-app 5001:5001
```

App-service can be accessed through http://localhost:5001
App-service metrics can be accessed through http://localhost:5001/metrics

---

### 6. Access Prometheus UI

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Prometheus can be accessed through http://localhost:9090

Open [http://localhost:9090](http://localhost:9090) in your browser.

### 7. Enable Email Alerts

1. Edit `values.yaml` and set your email and SMTP details under `.Values.alertmanager.email`.
2. If using Gmail with 2FA, create an [App Password](https://support.google.com/accounts/answer/185833?hl=en).
3. Create the SMTP password secret:

```bash
   kubectl create secret generic kube-prometheus-stack-alertmanager-secret --from-literal=smtpPassword='your-app-password' -n monitoring
   kubectl delete pod alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring
   cd helm/restaurant-sentiment && helm upgrade sentiment .
```

### 8. Test Alerts

Generate traffic to trigger alerts:

```bash
while true; do curl -s http://localhost:5001/ > /dev/null; done
```

### 9. Debugging

If you update your app image or Helm chart and want to redeploy:

```bash
kubectl rollout restart deployment app
cd helm/restaurant-sentiment
helm upgrade sentiment .
```

---

### 8. Creating and Acessing Grafana

Run the following line to start Grafana Dashboard

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

Grafana Dashboard can be accessed through http://localhost:3000

Admin login username and password:

Username: Admin
Password: prom-operator

The dashboard should be visible under the name "Restaurant Sentiment Dashboard"

If a new image is pulled and you want to rerun the grafana, run these commands:

```bash
kubectl rollout restart deployment prometheus-grafana -n monitoring
```
