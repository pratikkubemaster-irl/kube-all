# AKS Cluster Setup Guide for CKA Labs

This guide ensures your AKS cluster is properly configured to support all labs in this course.

## ✅ Prerequisites

- AKS cluster already created and accessible
- `kubectl` installed locally
- Azure CLI installed and authenticated
- Connected to AKS cluster in VS Code

## 🔧 Cluster Configuration Checklist

### 1. Verify kubectl Connection

```bash
# Test cluster connectivity
kubectl cluster-info
kubectl get nodes

# Expected output: Should show your nodes
NAME                               STATUS   ROLES   AGE   VERSION
aks-nodepool1-12345678-vmss000000  Ready    agent   X days  v1.28.0
```

### 2. Check RBAC is Enabled

```bash
# Verify RBAC is enabled
kubectl get clusterrolebinding | head -5

# Should show system RBAC resources
```

### 3. Verify Storage Classes

```bash
# Check available storage classes for storage labs
kubectl get storageclass

# Expected: Should include managed-premium, managed-csi, or similar
```

If none is shown, AKS defaults are usually available implicitly.

### 4. Check Networking

```bash
# Verify CNI plugin
kubectl get daemonset -n kube-system | grep -E "calico|azure|cni"

# Check CoreDNS
kubectl get pods -n kube-system | grep coredns

# Expected: CoreDNS pods should be running
```

### 5. Create Lab Namespace

Create a dedicated namespace for all labs:

```bash
# Create namespace for all labs
kubectl create namespace cka-labs

# Verify
kubectl get namespace | grep cka-labs

# Set as default (optional)
kubectl config set-context --current --namespace=cka-labs
```

### 6. Create Test Resources

```bash
# Test that you can create resources
kubectl run test-pod --image=nginx --namespace=cka-labs
kubectl get pods -n cka-labs

# Clean up
kubectl delete pod test-pod -n cka-labs
```

## 📋 AKS-Specific Configuration

### Using Azure Storage Classes

All AKS clusters come with built-in storage classes:

```bash
# List all storage classes
kubectl get storageclasses

# Typical AKS storage classes:
# - default - Azure Disk (Standard)
# - managed-premium - Azure Disk (Premium SSD)
# - azurefile - Azure Files (SMB)
# - azurefile-premium - Azure Files (Premium)
```

**For labs:** Most labs use the default storage class. AKS automatically provides one.

### Troubleshooting Storage

If PersistentVolume creation fails:

```bash
# Check events
kubectl describe pvc <pvc-name> -n cka-labs

# Common issue: Subscription quota exceeded
# Solution: Use `delete-unused-pvs.sh` from troubleshooting folder
```

## 🔐 RBAC Setup for Labs

### Create Lab Service Account

```bash
# Create service account for security labs
kubectl create serviceaccount lab-sa -n cka-labs

# Create role for labs
kubectl create role lab-role \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=pods,services,deployments \
  -n cka-labs

# Bind role to service account
kubectl create rolebinding lab-rolebinding \
  --role=lab-role \
  --serviceaccount=cka-labs:lab-sa \
  -n cka-labs
```

## 📝 Label Your Nodes

Some scheduling labs require node labels. Label your nodes:

```bash
# Get node names
kubectl get nodes

# Label nodes (replace node-name with actual names)
kubectl label nodes <node-name> disktype=ssd
kubectl label nodes <node-name> workload=compute

# Verify
kubectl get nodes --show-labels
```

## 🚀 Quick Verification Script

Save this as `verify-setup.sh` and run to verify everything:

```bash
#!/bin/bash

echo "=== CKA Lab Environment Verification ==="
echo ""

echo "✓ Cluster Info:"
kubectl cluster-info | head -2

echo ""
echo "✓ Nodes:"
kubectl get nodes --no-headers | wc -l
echo "  nodes available"

echo ""
echo "✓ Storage Classes:"
kubectl get sc --no-headers | wc -l
echo "  storage classes available"

echo ""
echo "✓ Namespaces:"
kubectl get ns | grep cka-labs

echo ""
echo "✓ Test Permissions:"
kubectl auth can-i create pods --namespace=cka-labs

echo ""
echo "✓ CoreDNS:"
kubectl get pods -n kube-system -l k8s-app=kube-dns --no-headers | wc -l
echo "  DNS pods running"

echo ""
echo "=== All checks passed! Ready for labs ==="
```

Run it:
```bash
bash verify-setup.sh
```

## 🔑 Configure Local kubeconfig

Ensure your local `kubeconfig` is accessible:

```bash
# Get AKS cluster credentials
az aks get-credentials --resource-group <RG-NAME> --name <CLUSTER-NAME>

# Verify kubeconfig
echo $KUBECONFIG
cat ~/.kube/config | head -10
```

## 🛑 Cleanup Between Labs

Each lab is isolated, but to clean up after labs:

```bash
# Delete all resources in cka-labs namespace (DESTRUCTIVE!)
kubectl delete all --all -n cka-labs

# Delete specific resource
kubectl delete deployment <name> -n cka-labs

# Delete persistent volumes created by labs
kubectl delete pvc --all -n cka-labs
```

**⚠️ WARNING:** These commands are destructive. Don't run unless you want to delete all resources.

## 🆘 Common AKS Issues & Solutions

### Issue: Pod can't pull image
```bash
# Cause: Likely authorization issue
# Solution: Use public images (nginx, busybox, etc.) for labs
```

### Issue: PersistentVolume stuck in Pending
```bash
# Check pod status
kubectl describe pvc <name> -n cka-labs

# Common cause: Region/zone mismatch
# Solution: Verify node availability zones match PVC spec
```

### Issue: Network policies not enforced
```bash
# Verify CNI supports network policies
kubectl get daemonset -n kube-system

# If Azure CNI is used with network policy support:
kubectl get netpol -n cka-labs
```

### Issue: Insufficient resources
```bash
# Check node capacity
kubectl top nodes
kubectl describe nodes | grep -A5 "Allocated resources"

# If limited: Delete unused PVCs and pods
```

## 📦 Required Tools

Ensure these are installed locally:

```bash
# Check kubectl
kubectl version --client

# Check Azure CLI
az --version

# Optional but helpful
docker --version  # For container image testing
```

## ✨ You're Ready!

Once all checks pass, you're ready to start labs. Go to [index.md](./index.md) to begin with Day 1!

---

**Next Step:** Start with [Cluster Basics - Day 1](./cluster-basics/README.md)
