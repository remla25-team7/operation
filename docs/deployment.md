## Deployment Documentation

This document provides a detailed overview of the deployment structure and data flow for the Restaurant Sentiment Analysis system deployed on a Kubernetes cluster using **Istio** as the service mesh. It is intended to clearly explain resource relationships, traffic routing, and the overall system architecture.

---

### 1. Deployment Structure

The system is composed of modular services, each serving a specific role in the application pipeline:

#### Core Components

* **App Image**

  * **[app-service](https://github.com/remla25-team7/app)**: A Flask-based web application that serves both as a frontend and backend API. It interacts with the user and forwards user-submitted input to the model-service. It also imports [`lib-version`](https://github.com/remla25-team7/lib-version) to expose versioning metadata via API.

* **Model Image**

  * **[model-service](https://github.com/remla25-team7/model-service)**: A Flask REST service that loads a trained sentiment classification model. It relies on [`lib-ml`](https://github.com/remla25-team7/lib-ml) for text preprocessing and prediction utilities.

* **Model Training**

  * **[model-training](https://github.com/remla25-team7/model-training)**: A standalone pipeline that trains and evaluates the ML model. This pipeline is triggered via GitHub Actions and stores the resulting model artifact in a public location, accessible to the model-service at runtime.

* **Deployment & Operations**

  * **[operation](https://github.com/remla25-team7/operation)**: Contains all Kubernetes manifests, Helm charts, Docker Compose files, and documentation related to provisioning, deployment, and monitoring.

---

#### Infrastructure and Observability

* **Istio Gateway**: Entry point for external traffic into the mesh.
* **VirtualService**: Routes traffic between services and handles A/B or canary testing logic (currently configured for a 60/40 traffic split).
* **DestinationRule**: Defines routing subsets based on service versions.
* **Prometheus & Grafana**: Used to scrape metrics from services and visualize them.
* **Kubernetes Dashboard**: Optional GUI to inspect deployed resources.
* **MetalLB**: Provides external IP allocation on bare-metal clusters.

---

#### Supporting Resources

* **ConfigMaps**: Used to configure runtime parameters like model URLs and app metadata.
* **Secrets**: Used to inject sensitive credentials via environment variables.
* **ServiceMonitor**: Prometheus CRD to detect and scrape metrics endpoints.
* **HostPath Shared Volume**: A persistent path (`/mnt/shared`) used to share read/write files between services during development and debugging.
* **Helm values.yaml**: Provides configurable settings for image versions, resource limits, routing behavior, and service hostnames.

---

### 2. Multi-Environment Deployment

The Helm setup supports multiple independent environments:

* Separate deployments like `dev` and `prod` are distinguished via release names.
* Custom Ingress hostnames (e.g., `dev-app.local`, `prod-app.local`) ensure separation.
* Each deployment can run a different model or version of the app-service independently.

---

### 3. Visual Architecture Overview

![Deployment Architecture](./images/istio-service-mesh-diagram.png)

*Note: This diagram represents Istio-based routing between services through the mesh, not direct local service links.*

---

### 4. Data Flow and Routing Behavior

The request and response path proceeds as follows:

1. **User Access**: A browser sends a request to `app.local` (or `dev-app.local`, etc.).
2. **IngressGateway**: Istio receives traffic and routes it via `VirtualService` to the app-service.
3. **App-Service to Model-Service**: The app-service calls the model-service over internal service mesh networking.
4. **Prediction**: The model-service processes the input and returns a prediction.
5. **Response Propagation**: The app-service returns the prediction to the user.
6. **Monitoring**: Prometheus gathers metrics exposed via `/metrics` endpoints on both app-service and model-service, configured using `ServiceMonitor`.

#### Dynamic Routing

* During experiments, **Istio splits traffic** between versions (e.g., 60% to `model-v1`, 40% to `model-v2`) via `VirtualService`.
* These rules allow controlled feature rollouts, model A/B testing, and metric-based decisions in Grafana.

---

### 5. Resource Overview

| Component               | Type            | Namespace            | Istio-enabled | Description                          |
|------------------------|-----------------|----------------------|----------------|--------------------------------------|
| app-service             | Deployment      | sentiment            | Yes           | Serves frontend and backend logic     |
| model-service           | Deployment      | sentiment            | Yes           | Handles sentiment prediction          |
| istio-ingressgateway    | Deployment      | istio-system         | N/A           | Entry point for external traffic      |
| prometheus              | StatefulSet     | monitoring           | No            | Metrics scraper                       |
| grafana                 | Deployment      | monitoring           | No            | Dashboards for observability         |
| config-map/app-config   | ConfigMap       | sentiment            | N/A           | Runtime configuration                 |
| secret/api-keys         | Secret          | sentiment            | N/A           | Contains credentials                  |
| shared-volume           | HostPath Volume | sentiment            | N/A           | Shared volume mounted at `/mnt/shared` |

---

### 6. Summary

This documentation outlines the current state of the deployed system, with focus on modular components, Istio traffic management, and observability integration. It aligns with the course goals of deploying a monitored, multi-service, experiment-ready ML application.