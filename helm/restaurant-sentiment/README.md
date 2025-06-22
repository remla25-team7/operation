# Restaurant Sentiment Analyzer Helm Chart

A Helm chart for deploying the Restaurant Sentiment Analyzer application on Kubernetes.

## Features

- **App Service**: Web application for sentiment analysis
- **Model Service**: Machine learning model service
- **Ingress**: External access through NGINX Ingress Controller
- **Monitoring**: Prometheus ServiceMonitors for metrics collection
- **ConfigMaps & Secrets**: Configuration management
- **HostPath Volumes**: Shared storage mounting

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- NGINX Ingress Controller
- Prometheus Operator (for monitoring)

## Installation

### Basic Installation

```bash
helm install restaurant-sentiment ./helm/restaurant-sentiment
```

### Installation with Custom Values

```bash
helm install restaurant-sentiment ./helm/restaurant-sentiment \
  --set app.image=ghcr.io/remla25-team7/app:v1.0.0 \
  --set modelService.image=ghcr.io/remla25-team7/model-service:v1.0.0
```

### Multiple Installations

You can run multiple copies of the same application in your cluster (e.g., one for development, one for production). Here's how:

**Step 1: Install for different environments**
```bash
# Install development version
helm install dev ./helm/restaurant-sentiment \
  --set app.host=dev-app.local \
  --set modelService.host=dev-model.local

# Install production version  
helm install prod ./helm/restaurant-sentiment \
  --set app.host=prod-app.local \
  --set modelService.host=prod-model.local
```

**Step 2: Add hostnames to your computer's hosts file**
```bash
# Add these lines to /etc/hosts (replace 192.168.56.95 with your actual ingress IP)
192.168.56.95 dev-app.local dev-model.local
192.168.56.95 prod-app.local prod-model.local
```

**Step 3: Access your applications**
- Development: Open `http://dev-app.local` in your browser
- Production: Open `http://prod-app.local` in your browser
- Model API: Use `http://dev-model.local/` or `http://prod-model.local/` for predictions

**What happens:**
- You get two completely separate applications running
- Each has its own pods, services, and configuration (with names like `dev-restaurant-sentiment-app`, `prod-restaurant-sentiment-model`, etc.)
- They don't interfere with each other
- You can test changes in dev before deploying to prod

## Configuration

### Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.image` | App service image | `ghcr.io/remla25-team7/app:latest` |
| `app.port` | App service port | `5001` |
| `app.host` | App ingress host | `app.local` |
| `modelService.image` | Model service image | `ghcr.io/remla25-team7/model-service:latest` |
| `modelService.port` | Model service port | `5000` |
| `modelService.host` | Model ingress host | `model.local` |
| `monitoring.enabled` | Enable monitoring | `true` |
| `sharedVolumePath` | HostPath volume path | `/mnt/shared` |

### Access Points

- **App Service**: `http://app.local/`
- **Model Service**: `http://model.local/predict`
- **Metrics**: `http://app.local/metrics`

## Architecture

```
┌─────────────────┐    ┌──────────────────┐
│   Ingress       │    │   Ingress        │
│   (app.local)   │    │   (model.local)  │
└─────────┬───────┘    └──────────┬───────┘
          │                       │
          ▼                       ▼
┌─────────────────┐    ┌──────────────────┐
│   App Service   │    │  Model Service   │
│   (port 5001)   │    │   (port 5000)    │
└─────────┬───────┘    └──────────┬───────┘
          │                       │
          ▼                       ▼
┌─────────────────┐    ┌──────────────────┐
│   App Pod       │    │   Model Pod      │
│   + ConfigMap   │    │   + ConfigMap    │
│   + Secret      │    │   + Secret       │
│   + HostPath    │    │   + HostPath     │
└─────────────────┘    └──────────────────┘
```

## Monitoring

When monitoring is enabled, the chart creates ServiceMonitors for both services:

- **App ServiceMonitor**: Scrapes metrics from `/metrics` endpoint
- **Model ServiceMonitor**: Scrapes metrics from `/metrics` endpoint

## Shared Storage

Both services mount the same hostPath volume at `/mnt/shared` for shared data access.

## Uninstallation

```bash
helm uninstall restaurant-sentiment
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/instance=restaurant-sentiment
```

### Check Services
```bash
kubectl get svc -l app.kubernetes.io/instance=restaurant-sentiment
```

### Check Ingress
```bash
kubectl get ingress -l app.kubernetes.io/instance=restaurant-sentiment
```

### View Logs
```bash
kubectl logs -l app.kubernetes.io/component=app
kubectl logs -l app.kubernetes.io/component=model
```

## Verification

### Check Installation Status

```bash
# Check if Helm releases exist
helm list

# Check if pods are running
kubectl get pods -l app.kubernetes.io/instance=<release-name>

# Check if services are created
kubectl get svc -l app.kubernetes.io/instance=<release-name>

# Check if Ingress is configured
kubectl get ingress -l app.kubernetes.io/instance=<release-name>
```

### Verify Multiple Installations

```bash
# Check all releases
helm list

# Verify separate resources for each installation
kubectl get pods -l app.kubernetes.io/instance=dev
kubectl get pods -l app.kubernetes.io/instance=prod
```

### Test Access

```bash
# Add hostnames to /etc/hosts
echo "192.168.56.95 <app-host> <model-host>" | sudo tee -a /etc/hosts

# Test app access
curl -I http://<app-host>

# Test model service
curl -X POST -H "Content-Type: application/json" \
  -d '{"review": "Great food!"}' \
  http://<model-host>/
```

### Run Helm Tests

```bash
# Run automated tests
helm test <release-name>
``` 