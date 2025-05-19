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

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/)  
- [Docker Compose](https://docs.docker.com/compose/)  

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

3. **Define the API key for the Model Service**

   ```bash
   echo "API_KEY=your_actual_key_here" > secrets/model_credentials.txt
   ```

4. **Start all services**

   ```bash
   docker-compose up -d
   ```



## Code Structure

| File / Directory                | Purpose                                                                                                          |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `docker-compose.yml`            | Primary Docker Compose configuration file                                                                        |
| `.env`                          | Environment variables (ports, versions, resource limits)                                                         |
| `secrets/`                      | Secure storage for sensitive credentials (API keys, tokens, passwords); mounted at runtime and excluded from VCS |
| `secrets/model_credentials.txt` | Stores the API key for model authentication (excluded from VCS)                                                  |

---

## Assignment Progress Log

### Assignment A1

* **Model-Training**

  * Created the ML training pipeline using a Hugging Face model.
* **Model-Service**

  * Containerized the ML model with Docker and exposed it via a Flask REST API.
  * Implemented a GitHub Actions workflow to automatically build and publish the container.
* **Lib-ML**

  * Standardized preprocessing in a PyPI package used by both training and the model service.
* **Lib-Version**

  * Built a version-checker utility for the app service.
* **App**

  * Developed a Dockerized web application using HTML/Bootstrap 5 (frontend) and Flask (backend).
* **Operation**

  * Centralized deployment configurations in this repository, featuring Docker Compose and detailed README instructions.

### Assignment A2

#### Prerequisites

* **Vagrant** & **VirtualBox** installed
* **Ansible 2.18+** on host (or use the bundled Vagrant provisioner)
* Host OS user must be able to edit `/etc/hosts`

#### 1. Clone & Spin Up

```bash
git clone <repo-url> && cd <repo-dir>
vagrant up
```

This will:

1. Boot **ctrl**, **node-1**, and **node-2** VMs
2. Run Ansible to install Kubernetes, containerd, MetalLB, nginx-ingress, and the Dashboard

#### 2. Point `dashboard.local` at the Load Balancer IP

Add the following line to your host’s `/etc/hosts`:

```
192.168.56.95   dashboard.local
```

#### 3. Browse the Dashboard

Open in your browser:

```
https://dashboard.local/
```

#### 4. Log in as Admin

Retrieve your token on the control VM:

```bash
vagrant ssh ctrl
kubectl -n kubernetes-dashboard create token admin-user
```
### Assignment 3
#### 1. Install Istio (Manual)

1. SSH into the control VM:

   ```bash
   vagrant ssh ctrl
   ```

2. Install Istio with the demo profile:

   ```bash
   istioctl install --set profile=demo --skip-confirmation
   ```

   This will install Istio without waiting for confirmation.
