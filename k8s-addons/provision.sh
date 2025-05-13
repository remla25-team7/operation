#!/bin/bash
set -e

echo "[Step 1] Installing MetalLB..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

echo "[Step 2] Waiting for MetalLB pods to be ready..."
kubectl wait --namespace metallb-system --for=condition=Ready pods --all --timeout=120s

echo "[Step 3] Applying MetalLB IPPool and L2Advertisement..."
kubectl apply -f metallb-ippool.yaml
kubectl apply -f metallb-l2adv.yaml

echo "[Step 4] Deploying NGINX Ingress Controller via Helm..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -f ingress-nginx-values.yaml

echo "[Step 5] Deploying Kubernetes Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl apply -f dashboard-admin-user.yaml

echo "[Step 6] Deploying smoke test sample app..."
kubectl apply -f test-deployment.yaml

echo "[Step 7] Waiting for all deployments to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/smoke-app
kubectl wait --namespace ingress-nginx --for=condition=Ready pods --all --timeout=120s

echo "[Step 8] Listing services and LoadBalancer IPs..."
kubectl get svc

echo "[Step 9] Verifying test app is reachable (manual curl recommended if IP is assigned)..."
echo "Check the EXTERNAL-IP of the 'smoke-app' service above and test with:"
echo "  curl http://<EXTERNAL-IP>"
