# Kubernetes Add-ons for REMLA25 Team 7 Operation

This directory contains Kubernetes add-on manifests, provisioning script, and testing resources used for enhancing and validating a Kubernetes cluster deployment in the [REMLA25 Team 7 Operation project](https://github.com/remla25-team7/operation).

## Files Overview

- **`metallb-ippool.yaml`**  
  Defines a pool of IP addresses for MetalLB to assign to services of type `LoadBalancer`.

- **`metallb-l2adv.yaml`**  
  Sets up Layer 2 (L2) advertisement for MetalLB so that IPs from the pool are properly announced.

- **`dashboard-admin-user.yaml`**  
  Creates a ServiceAccount with ClusterRoleBinding to allow admin access to the Kubernetes dashboard.

- **`ingress-nginx-values.yaml`**  
  Helm chart values file for customizing the NGINX Ingress Controller installation.

- **`test-deployment.yaml`**  
  Simple test application used to verify that networking, ingress, and MetalLB are functioning correctly.

- **`provision.sh`**  
  Shell script to provision all the Kubernetes add-ons in the correct order.

---

## 🚀 Quick Start

1. **Ensure your Kubernetes cluster is running** and `kubectl` is configured.

2. **Make the script executable** and run:

   ```bash
   chmod +x provision.sh
   ./provision.sh
