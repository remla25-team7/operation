# 🚀 Running the Restaurant Sentiment Analyzer (Assignments 1–3)

This guide explains how to run the full application stack for the Restaurant Sentiment Analyzer project, including setup through Assignments 1–3.

---

## 📆 Prerequisites

Install the following tools:

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [Docker Desktop](https://www.docker.com/products/docker-desktop) (ensure Docker Daemon is running)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm](https://helm.sh/docs/intro/install/)
* Git

Optional (for accessing the app):

* Add the following line to your `/etc/hosts` file:

  ```
  192.168.56.95  app.local model.local dashboard.local
  ```

> **Tip**: On macOS or Linux, edit `/etc/hosts` using `sudo nano /etc/hosts`.
> On Windows, open `C:\Windows\System32\drivers\etc\hosts` with Notepad (Run as Administrator).

---

## 📁 Project Structure

```
operation/
├── Vagrantfile
├── kubeconfig
├── kubernetes/                 # Raw Kubernetes manifests (used earlier)
├── helm/
│   └── restaurant-sentiment/   # ✅ Helm chart used for Assignment 3
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment-app.yaml
│           ├── deployment-model.yaml
│           ├── service-app.yaml
│           ├── service-model.yaml
│           ├── ingress.yaml
│           ├── configmap.yaml
│           └── secret.yaml
```

---

## 🛠️ Step-by-Step Setup

### 1. Clone and Switch to Correct Branch

```bash
git clone https://github.com/remla25-team7/operation.git
cd operation
git checkout kubernetes-usage
```

### 2. Boot the Kubernetes Cluster

```bash
vagrant up
vagrant provision
```

### 3. Set KUBECONFIG (host terminal)

```bash
export KUBECONFIG=$(pwd)/kubeconfig  # macOS/Linux
```

> On Windows (Git Bash or PowerShell), set it like this:
>
> ```
> $env:KUBECONFIG="$(Get-Location)\kubeconfig"
> ```

### 4. Verify Cluster is Ready

```bash
kubectl get nodes
```

All nodes (`ctrl`, `node-1`, `node-2`) should show `Ready`.

---

## 🚢 Deploying the App with Helm (Assignment 3)

### 1. Navigate to the Helm Chart Directory

```bash
cd helm/restaurant-sentiment
```

### 2. Update `values.yaml` with Image Names

```yaml
app:
  image: ghcr.io/remla25-team7/app:latest
  port: 5001
  host: app.local

modelService:
  image: ghcr.io/remla25-team7/model-service:latest
  port: 8080
  host: model.local
```

> To find your image names:
>
> * Run `docker images` on your local system (Docker Desktop must be running)
> * Or visit [GitHub Container Registry](https://github.com/orgs/remla25-team7/packages)
> * Use the format `ghcr.io/ORG/REPO:TAG`

### 3. Install the Helm Chart

```bash
helm install sentiment .
```

### 4. Check Pods and Services

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

### 5. Access the Application

* Open [http://app.local](http://app.local) in your browser
* To test model endpoint: `curl -X POST http://model.local/predict`

---

## 📚 Libraries Used (in App/Model)

Make sure these Python libraries are installed in the Docker images:

```text
flask
requests
joblib
scikit-learn
prometheus_client   # TODO: expose Prometheus metrics from Flask apps
```

---

## 📊 Assignment 3 To-Dos

* [ ] Add `/metrics` endpoint to both app and model-service using `prometheus_client`
* [ ] Deploy Prometheus via Helm or K8s manifests
* [ ] Create a `ServiceMonitor` to scrape the metrics
* [ ] Deploy Grafana via Helm
* [ ] Create and load a custom Grafana dashboard
* [ ] Optional: Configure AlertManager with Prometheus rules

---

## ✅ Summary

You're now able to deploy the full system with one `helm install` command. The next step is to instrument the app with Prometheus metrics and set up observability tools to monitor it.
