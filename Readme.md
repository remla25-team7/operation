## Operation

### Overview

This repository serves as the main entrypoint for the Sentiment Analysis System for Restaurant Reviews. It includes a Docker Compose configuration to streamline deployment and simplify operational management of the application.

#### Related Repositories

* [Model Training](https://github.com/remla25-team7/model-training)
* [Model Service](https://github.com/remla25-team7/model-service)
* [Library for Machine Learning (lib-ml)](https://github.com/remla25-team7/lib-ml)
* [Library for Versioning (lib-version)](https://github.com/remla25-team7/lib-version)
* [Application Frontend and Service (app)](https://github.com/remla25-team7/app)

---

## Getting Started

### Prerequisites

* Docker
* Docker Compose

### Running the Application

1. **Clone this repository**

   ```bash
   git clone https://github.com/remla25-team7/operation.git
   cd operation
   ```
2. **Create the `secrets` folder** (if it doesn’t exist)

   ```bash
   mkdir -p secrets
   ```
3. **Define the API Key for the model service**

   ```bash
   echo "API_KEY=your_actual_key_here" > secrets/model_credentials.txt
   ```
4. **Start all services**

   ```bash
   docker-compose up -d
   ```

---

## Code Structure

| File / Directory                | Purpose                                                                                   |
| ------------------------------- | ----------------------------------------------------------------------------------------- |
| `docker-compose.yml`            | The primary Docker Compose configuration file                                             |
| `.env`                          | Environment variables configuration (ports, versions, resource limits)                    |
| `secrets/`                      | Secure storage for sensitive credentials (API keys, tokens, passwords) mounted at runtime |
| `secrets/model_credentials.txt` | API key for model authentication; excluded from version control for security              |

---

## Assignment Progress Log

### Assignment A1

* **Model-Training**: Created the ML training pipeline using a Hugging Face model.
* **Model-Service**: Containerized the ML model with Docker and exposed it via a Flask REST API; added a GitHub Actions workflow to build and publish the container.
* **Lib-ML**: Standardized preprocessing in a PyPI package, shared by both training and model-service components.
* **Lib-Version**: Built a version checker for the app service.
* **App**: Dockerized web application using HTML/Bootstrap 5 for the frontend and Flask for the backend.
* **Operation**: Central repository for deployment configurations, featuring Docker Compose and detailed README instructions.

### Assignment A2

#### Prerequisites

* **Vagrant** & **VirtualBox** installed
* **Ansible 2.18+** on host (or use the bundled Vagrant provisioner)
* OS user with privileges to edit `/etc/hosts`

#### 1. Clone & Spin Up

```bash
git clone <repo-url> && cd <repo-dir>
vagrant up --provision
```

This will:

1. Boot the **ctrl**, **node-1**, and **node-2** VMs
2. Run Ansible to install Kubernetes, containerd, MetalLB, nginx-ingress, and the Kubernetes Dashboard

#### 2. Point `dashboard.local` at the Load Balancer IP

Add the following line to your host’s `/etc/hosts`:

```text
192.168.56.95   dashboard.local
```

#### 3. Browse the Dashboard

Open your browser and navigate to:

```text
https://dashboard.local/
```

#### 4. Log in as Admin

Retrieve your token on the control VM:

```bash
vagrant ssh ctrl
kubectl -n kubernetes-dashboard create token admin-user
```

---

### Kubernetes Add‑ons for REMLA25 Team 7 Operation

This directory contains Kubernetes add‑on manifests, a provisioning script, and testing resources used for enhancing and validating a Kubernetes cluster deployment in the [REMLA25 Team 7 Operation project](https://github.com/remla25-team7/operation).

#### Files Overview

* **`metallb-ippool.yaml`**        Defines an IP pool for MetalLB to assign to `LoadBalancer` services.
* **`metallb-l2adv.yaml`**         Configures Layer 2 advertisement for MetalLB.
* **`dashboard-admin-user.yaml`**  Creates a ServiceAccount with ClusterRoleBinding for dashboard admin access.
* **`ingress-nginx-values.yaml`**  Helm values for customizing the NGINX Ingress Controller installation.
* **`test-deployment.yaml`**       Simple test app to verify networking, ingress, and MetalLB functionality.
* **`provision.sh`**               Shell script to provision all add‑ons in the correct order.

---

## 🚀 Quick Start

1. **Ensure your Kubernetes cluster is running** and `kubectl` is configured.
2. **Make the script executable** and run:

   ```bash
   chmod +x provision.sh
   ./provision.sh
   ```
