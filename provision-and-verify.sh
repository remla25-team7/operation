#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Kubernetes provisioning..."

# Step 1: Start the Vagrant VMs with provisioning
echo "Bringing up Vagrant machines with provisioning..."
vagrant up --provision

# Step 2: Wait until all VMs respond to Ansible ping
echo "Waiting for VMs to respond to Ansible ping..."
for attempt in {1..10}; do
    if ansible all -m ping; then
        echo "All VMs are reachable via Ansible."
        break
    fi
    echo "Not all VMs reachable yet. Retrying in 10 seconds..."
    sleep 10
    if [ "$attempt" -eq 10 ]; then
        echo "Failed to reach all VMs via Ansible after multiple attempts."
        exit 1
    fi
done

# Step 3: Copy kubeconfig from controller VM
echo "Copying kubeconfig from controller..."
vagrant ssh ctrl -c "sudo cat /etc/kubernetes/admin.conf" > kubeconfig

# Step 4: Export kubeconfig for kubectl
export KUBECONFIG=$(pwd)/kubeconfig
echo "KUBECONFIG set to $(pwd)/kubeconfig"

# Step 5: Wait for all Kubernetes nodes to be ready
echo "Waiting for all Kubernetes nodes to be Ready..."
for i in {1..24}; do
    not_ready=$(kubectl get nodes --no-headers | awk '$2 != "Ready" {print $1}')
    if [ -z "$not_ready" ]; then
        echo "All nodes are Ready."
        break
    fi
    echo "Nodes not ready yet: $not_ready"
    sleep 5
    if [ "$i" -eq 24 ]; then
        echo "Timed out waiting for all nodes to become Ready."
        exit 1
    fi
done

# Step 6: Run finalization playbook
echo "Running finalization Ansible playbook..."
ansible-playbook -i inventory.cfg ./playbooks/finalization.yml

# Step 7: Showcase Kubernetes setup
echo "Verifying cluster status..."
kubectl get nodes
kubectl get pods -A

echo "Verifying MetalLB and Ingress Controller..."
kubectl get pods -n metallb-system
kubectl get pods -n ingress-nginx

echo "To access the Kubernetes Dashboard:"
echo "    Visit: https://dashboard.local"
echo "    Get token by running:"
echo "       kubectl -n kubernetes-dashboard create token admin-user"

echo "Provisioning and verification complete."

echo "  !!To use kubectl or helm in your shell, run this:"
echo "   export KUBECONFIG=$(pwd)/kubeconfig"