#!/bin/bash

# Test script for Restaurant Sentiment Helm Chart
set -e

CHART_NAME="restaurant-sentiment"
CHART_PATH="helm/restaurant-sentiment"
RELEASE_NAME="test-restaurant-sentiment"

echo "Testing Restaurant Sentiment Helm Chart"
echo "=========================================="

# Function to cleanup test resources
cleanup() {
    echo "Cleaning up test resources..."
    helm uninstall $RELEASE_NAME 2>/dev/null || true
    kubectl delete pod -l app.kubernetes.io/instance=$RELEASE_NAME 2>/dev/null || true
    echo "Cleanup completed"
}

# Set up cleanup on script exit
trap cleanup EXIT

# Test 1: Helm lint
echo "Test 1: Helm lint"
if helm lint $CHART_PATH; then
    echo "Helm lint passed"
else
    echo "Helm lint failed"
    exit 1
fi

# Test 2: Helm template
echo "Test 2: Helm template"
if helm template $RELEASE_NAME $CHART_PATH > /dev/null; then
    echo "Helm template passed"
else
    echo "Helm template failed"
    exit 1
fi

# Test 3: Install chart
echo "Test 3: Install chart"
if helm install $RELEASE_NAME $CHART_PATH --wait --timeout=5m; then
    echo "Chart installation passed"
else
    echo "Chart installation failed"
    exit 1
fi

# Test 4: Wait for pods to be ready
echo "Test 4: Wait for pods to be ready"
sleep 10
if kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=$RELEASE_NAME --timeout=300s; then
    echo "All pods are ready"
else
    echo "Pods are not ready"
    kubectl get pods -l app.kubernetes.io/instance=$RELEASE_NAME
    exit 1
fi

# Test 5: Run Helm tests
echo "Test 5: Run Helm tests"
if helm test $RELEASE_NAME --timeout=300s; then
    echo "Helm tests passed"
else
    echo "Helm tests failed"
    exit 1
fi

# Test 6: Verify services
echo "Test 6: Verify services"
if kubectl get service $RELEASE_NAME-app && kubectl get service $RELEASE_NAME-model; then
    echo "Services are created"
else
    echo "Services are missing"
    exit 1
fi

# Test 7: Verify ConfigMaps
echo "Test 7: Verify ConfigMaps"
if kubectl get configmap $RELEASE_NAME-env-config && kubectl get configmap $RELEASE_NAME-model-env-config; then
    echo "ConfigMaps are created"
else
    echo "ConfigMaps are missing"
    exit 1
fi

# Test 8: Verify Secrets
echo "Test 8: Verify Secrets"
if kubectl get secret $RELEASE_NAME-app-secret && kubectl get secret $RELEASE_NAME-model-secret; then
    echo "Secrets are created"
else
    echo "Secrets are missing"
    exit 1
fi

# Test 9: Test connectivity
echo "Test 9: Test connectivity"
APP_POD=$(kubectl get pod -l app.kubernetes.io/instance=$RELEASE_NAME,app.kubernetes.io/component=app -o jsonpath='{.items[0].metadata.name}')
if kubectl exec $APP_POD -- curl -f http://$RELEASE_NAME-model:5000/health; then
    echo "App can reach model service"
else
    echo "App cannot reach model service"
    exit 1
fi

echo ""
echo "All tests passed! Your Helm chart is working correctly."
echo "==========================================" 