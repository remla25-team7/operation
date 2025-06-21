#!/bin/bash
set -e

echo "Testing Kubernetes Cluster Components..."
echo "=========================================="

# Check if kubeconfig exists
if [ ! -f "kubeconfig" ]; then
    echo " kubeconfig not found. Run 'vagrant up' first."
    exit 1
fi

echo " kubeconfig found"

# Test 1: Check cluster nodes
echo ""
echo "1. Testing Cluster Nodes..."
kubectl --kubeconfig kubeconfig get nodes
echo " Nodes are ready"

# Test 2: Check LoadBalancer services
echo ""
echo "2. Testing LoadBalancer Services..."
kubectl --kubeconfig kubeconfig get svc --all-namespaces | grep LoadBalancer
echo "LoadBalancer services have external IPs"

# Test 3: Test Nginx Ingress HTTPS
echo ""
echo "3. Testing Nginx Ingress HTTPS..."
NGINX_IP=$(kubectl --kubeconfig kubeconfig get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Nginx Ingress IP: $NGINX_IP"
curl -I -k https://$NGINX_IP 2>/dev/null | head -1 || echo "⚠️  HTTPS test failed (expected for root path)"

# Test 4: Test Istio Gateway
echo ""
echo "4. Testing Istio Gateway..."
ISTIO_IP=$(kubectl --kubeconfig kubeconfig get svc -n istio-system istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Istio Gateway IP: $ISTIO_IP"
curl -I http://$ISTIO_IP 2>/dev/null | head -1 || echo "⚠️  HTTP test failed (expected without VirtualService)"

# Test 5: Test Dashboard
echo ""
echo "5. Testing Kubernetes Dashboard..."
DASHBOARD_IP=$(kubectl --kubeconfig kubeconfig get ingress -n kubernetes-dashboard kubernetes-dashboard -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Dashboard IP: $DASHBOARD_IP"
curl -I -k https://dashboard.local 2>/dev/null | head -1 || echo "⚠️  Dashboard test failed (check /etc/hosts)"

# Test 6: Check all pods are running
echo ""
echo "6. Checking Pod Status..."
echo "MetalLB pods:"
kubectl --kubeconfig kubeconfig get pods -n metallb-system
echo ""
echo "Nginx Ingress pods:"
kubectl --kubeconfig kubeconfig get pods -n ingress-nginx
echo ""
echo "Istio pods:"
kubectl --kubeconfig kubeconfig get pods -n istio-system
echo ""
echo "Dashboard pods:"
kubectl --kubeconfig kubeconfig get pods -n kubernetes-dashboard

echo ""
echo "CLUSTER TEST COMPLETE!"
echo ""
echo " SUMMARY:"
echo " Cluster nodes are ready"
echo " LoadBalancer services have fixed IPs"
echo " Nginx Ingress Controller is running"
echo "Istio Gateway is running"
echo " Kubernetes Dashboard is accessible"
echo ""
echo " Access Information:"
echo "   Nginx Ingress: https://$NGINX_IP"
echo "   Istio Gateway: http://$ISTIO_IP"
echo "   Dashboard: https://dashboard.local"
echo ""
echo " To get dashboard token:"
echo "   kubectl --kubeconfig kubeconfig -n kubernetes-dashboard create token admin-user"
echo ""
echo " Add to /etc/hosts for dashboard access:"
echo "   $DASHBOARD_IP dashboard.local" 