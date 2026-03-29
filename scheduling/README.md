# Scheduling & Pod Placement Module

**Exam Weight:** 5%  
**Time Budget:** 6 minutes during exam

## Overview

Scheduling is about controlling WHERE pods run. The scheduler places pods on nodes based on constraints you specify. This module covers advanced scheduling features.

## Topics Covered

1. **Taints and Tolerations** - Control which pods can run on which nodes
2. **Node Affinity** - Pod preference for specific nodes
3. **Pod Affinity** - Pod preference for other pods
4. **Resource Requests & Limits** - Reserve node resources for pods

---

## ✅ Lab 1: Taints and Tolerations

**Duration:** 20 minutes  
**Objective:** Master node taints and pod tolerations

### Understanding Taints & Tolerations

**Taint** = Mark on node that repels pods (except those that tolerate it)  
**Toleration** = Permission for pod to run on tainted node

Use case: Reserve nodes for specific workloads, or prevent unwanted pods

### Step 1: Taint a Node

```bash
# Get your nodes
kubectl get nodes

# Add taint to node (repel all pods except those that tolerate)
kubectl taint nodes <node-name> workload=gpu:NoSchedule

# Taint syntax: key=value:effect
# Effects:
#   NoSchedule - Don't schedule new pods (ignore existing)
#   NoExecute  - Evict existing pods immediately
#   Prefer NoSchedule - Try to avoid, but allow if needed
```

### Step 2: Try to Schedule Pod on Tainted Node

```yaml
# manifests/untolerated-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: regular-pod
  namespace: cka-labs
spec:
  containers:
  - name: nginx
    image: nginx
```

```bash
kubectl apply -f manifests/untolerated-pod.yaml

# This pod will stay PENDING - can't run on tainted node!
kubectl describe pod regular-pod -n cka-labs
# Shows: "0/X nodes are available. X node(s) had taint"
```

### Step 3: Add Toleration to Pod

```yaml
# manifests/tolerated-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
  
  tolerations:
  - key: workload
    operator: Equal
    value: gpu
    effect: NoSchedule
```

```bash
kubectl apply -f manifests/tolerated-pod.yaml

# This pod CAN run on the tainted node!
kubectl get pods -n cka-labs
# gpu-pod should be Running
```

### Step 4: Remove Taint

```bash
# Remove taint with - at end
kubectl taint nodes <node-name> workload=gpu:NoSchedule-

# Regular pod should now stop pending and run
kubectl get pods -n cka-labs
```

---

## ✅ Lab 2: Node Affinity

**Duration:** 20 minutes  
**Objective:** Control pod placement on specific nodes

### Understanding Node Affinity

Node affinity = "I want my pod to run on nodes that meet these conditions"

Types:
- **requiredDuringSchedulingIgnoredDuringExecution** - MUST satisfy (hard)
- **preferredDuringSchedulingIgnoredDuringExecution** - TRY to satisfy (soft)

### Step 1: Label Nodes

```bash
# Label your nodes for testing
kubectl label nodes <node-1> disktype=ssd
kubectl label nodes <node-2> disktype=hdd

# Verify labels
kubectl get nodes --show-labels | grep disktype
```

### Step 2: Create Pod with Required Affinity

```yaml
# manifests/affinity-required.yaml
apiVersion: v1
kind: Pod
metadata:
  name: must-run-on-ssd
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
  
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
```

```bash
kubectl apply -f manifests/affinity-required.yaml

# Pod runs only on ssd node
kubectl get pods -n cka-labs -o wide | grep must-run-on-ssd
# NODE column shows ssd node
```

### Step 3: Create Pod with Preferred Affinity

```yaml
# manifests/affinity-preferred.yaml
apiVersion: v1
kind: Pod
metadata:
  name: prefer-ssd
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
  
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
```

```bash
kubectl apply -f manifests/affinity-preferred.yaml

# Tries to run on ssd, but if unavailable, runs elsewhere
kubectl get pods -n cka-labs -o wide | grep prefer-ssd
```

---

## ✅ Lab 3: Pod Affinity & Anti-Affinity

**Duration:** 25 minutes  
**Objective:** Control pod placement relative to other pods

### Pod Affinity = "Run near other pods"
Example: MySQL master and slave should run close together

### Pod Anti-Affinity = "Run away from other pods"
Example: Web front-ends should spread across nodes for fault tolerance

### Step 1: Create Reference Pod

```bash
# Deploy a pod to use as reference
kubectl run master-pod --image=busybox --namespace=cka-labs -- sleep 3600

# Label it so we can find it
kubectl label pod master-pod -n cka-labs app=master
```

### Step 2: Create Pod with Pod Affinity (Required)

```yaml
# manifests/pod-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: should-be-near-master
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
  
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - master
        topologyKey: kubernetes.io/hostname  # Same node
```

```bash
kubectl apply -f manifests/pod-affinity.yaml

# Should run on same node as master-pod
kubectl get pods -n cka-labs -o wide
# Both pods on same NODE
```

### Step 3: Create Pod with Pod Anti-Affinity

```yaml
# manifests/pod-antiaffinity.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: cka-labs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: app
        image: nginx
      
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - frontend
              topologyKey: kubernetes.io/hostname  # Different nodes
```

```bash
kubectl apply -f manifests/pod-antiaffinity.yaml

# Replicas spread across nodes
kubectl get pods -n cka-labs -o wide | grep frontend
# frontend pods on different NODEs
```

---

## ✅ Lab 4: Resource Requests & Limits

**Duration:** 20 minutes  
**Objective:** Reserve resources and prevent resource hogging

### Understanding Requests & Limits

**Request** = Minimum resources guaranteed to pod  
**Limit** = Maximum resources pod can use

Scheduler uses **requests** to make scheduling decisions!

### Step 1: Create Pod with Requests

```yaml
# manifests/pod-with-requests.yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        memory: "64Mi"      # Minimum 64MB
        cpu: "250m"         # Minimum 0.25 CPU
```

```bash
kubectl apply -f manifests/pod-with-requests.yaml

# View pod resource info
kubectl describe pod resource-pod -n cka-labs | grep -A5 "Requests\|Limits"
```

### Step 2: Create Pod with Limits

```yaml
# manifests/pod-with-limits.yaml
apiVersion: v1
kind: Pod
metadata:
  name: limited-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'while true; do :; done']  # CPU-heavy
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"     # Max 128MB
        cpu: "500m"         # Max 0.5 CPU
```

```bash
kubectl apply -f manifests/pod-with-limits.yaml

# If pod exceeds memory limit, it's killed
# If pod exceeds cpu limit, it's throttled

kubectl top pod limited-pod -n cka-labs  # Monitor usage
```

### Step 3: View Node Capacity vs Available

```bash
# See node total capacity
kubectl describe nodes <node-name> | grep -A3 "Capacity"

# See allocated/reserved
kubectl describe nodes <node-name> | grep -A5 "Allocated resources"

# Understand scheduling capacity
# If pod requests (CPU + Memory) > available, pod stays Pending
```

### Step 4: Create LimitRange (Namespace-wide defaults)

```yaml
# manifests/limitrange.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cka-limits
  namespace: cka-labs
spec:
  limits:
  - max:
      cpu: "1"              # Max per pod
      memory: "512Mi"
    min:
      cpu: "100m"           # Min per pod
      memory: "64Mi"
    type: Pod
  - max:
      cpu: "1"              # Max per container
      memory: "512Mi"
    min:
      cpu: "50m"            # Min per container
      memory: "32Mi"
    type: Container
```

```bash
kubectl apply -f manifests/limitrange.yaml

# Now any pod without explicit requests/limits gets these defaults
# Any pod trying to exceed limits is rejected
```

---

## 🎯 Quick Reference Table

| Feature | Use Case | Syntax |
|---------|----------|--------|
| Taint | Repel pods from node | `kubectl taint nodes <node> key=value:effect` |
| Toleration | Allow pod on tainted node | `tolerations:` in pod spec |
| Node Affinity | Pod likes specific nodes | `affinity.nodeAffinity:` |
| Pod Affinity | Pod likes other pods nearby | `affinity.podAffinity:` |
| Pod Anti-Affinity | Pod dislikes other pods nearby | `affinity.podAntiAffinity:` |
| Requests | Minimum resources needed | `resources.requests:` |
| Limits | Maximum resources allowed | `resources.limits:` |

---

## ✅ Lab Verification

- [ ] Created and removed taints
- [ ] Added tolerations to pods
- [ ] Labeled nodes for affinity
- [ ] Created node affinity pods
- [ ] Created pod affinity deployment
- [ ] Created pod anti-affinity deployment
- [ ] Set container resource requests/limits
- [ ] Created LimitRange

---

**Next:** [Networking Module](../networking/README.md)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)
