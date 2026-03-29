# Storage Module

**Exam Weight:** 10%  
**Time Budget:** 12 minutes during exam

## Overview

Storage is about persistent data in Kubernetes. This module covers volumes, persistent storage, and how stateful applications manage data.

## Topics Covered

1. **Volumes** - Temporary and persistent storage
2. **PersistentVolumes** - Cluster-scoped storage resources
3. **PersistentVolumeClaims** - Pod requests for storage
4. **StorageClasses** - Dynamic volume provisioning
5. **StatefulSets with Storage** - Stateful app data management

---

## ✅ Lab 1: Volumes & Mounts

**Duration:** 20 minutes  
**Objective:** Understand volume types and mounting

### Understanding Volumes

**Volume** = Storage attached to pod (survives pod restart, lost on pod deletion)

Types:
- **emptyDir** - Temporary storage (lost when pod deleted)
- **hostPath** - Storage on node (for node-local data)
- **configMap** - Config files injected as volume
- **secret** - Sensitive data injected as volume
- **persistentVolumeClaim** - Claim on persistent storage

### Step 1: Create Pod with emptyDir

```yaml
# manifests/pod-with-emptydir.yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-demo
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo "Hello from pod" > /data/message.txt && sleep 3600']
    volumeMounts:
    - name: data
      mountPath: /data
  
  volumes:
  - name: data
    emptyDir: {}
```

```bash
kubectl apply -f manifests/pod-with-emptydir.yaml

# Check file exists
kubectl exec storage-demo -n cka-labs -- cat /data/message.txt
# Output: Hello from pod

# Delete pod - data is gone!
kubectl delete pod storage-demo -n cka-labs
```

### Step 2: Create Pod with ConfigMap Volume

```bash
# Create ConfigMap
kubectl create configmap app-config --from-literal=key1=value1 -n cka-labs

# View ConfigMap
kubectl get configmap app-config -n cka-labs -o yaml
```

```yaml
# manifests/pod-with-configmap.yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'cat /etc/config/key1 && sleep 3600']
    volumeMounts:
    - name: config
      mountPath: /etc/config
  
  volumes:
  - name: config
    configMap:
      name: app-config
```

```bash
kubectl apply -f manifests/pod-with-configmap.yaml

# ConfigMap data mounted as files
kubectl exec config-pod -n cka-labs -- ls /etc/config
# Shows: key1

kubectl exec config-pod -n cka-labs -- cat /etc/config/key1
# Output: value1
```

---

## ✅ Lab 2: PersistentVolumes & PersistentVolumeClaims

**Duration:** 30 minutes  
**Objective:** Create persistent storage for data that survives pod deletion

### Understanding PV/PVC

**PersistentVolume (PV)** = Storage resource provisioned by admin  
**PersistentVolumeClaim (PVC)** = Pod requests storage from PV

Like: PV = parking lot, PVC = pod's parking space

### Step 1: Check Available Storage Classes

```bash
# See storage classes (PVC uses these to provision PV)
kubectl get storageclass

# AKS provides default storage classes:
# - default / managed-csi (Azure Disk)
# - managed-premium (Premium SSD)
# - azurefile (Azure Files)
```

### Step 2: Create PersistentVolumeClaim

```yaml
# manifests/pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: cka-labs
spec:
  accessModes:
    - ReadWriteOnce  # Only one pod can mount (read-write)
  storageClassName: default  # Use default storage class
  resources:
    requests:
      storage: 5Gi  # Request 5GB
```

```bash
kubectl apply -f manifests/pvc.yaml

# Check PVC status
kubectl get pvc -n cka-labs
# STATUS: Pending (until pod uses it)

# Check PV created
kubectl get pv
# Should auto-create matching this claim
```

### Step 3: Use PVC in Pod

```yaml
# manifests/pod-with-pvc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo "Persistent data" > /data/file.txt && sleep 3600']
    volumeMounts:
    - name: storage
      mountPath: /data
  
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: data-pvc
```

```bash
kubectl apply -f manifests/pod-with-pvc.yaml

# Check PVC is Bound
kubectl get pvc -n cka-labs
# STATUS: Bound

# Check file exists
kubectl exec data-pod -n cka-labs -- cat /data/file.txt
# Output: Persistent data
```

### Step 4: Test Data Persistence

```bash
# Delete and recreate pod
kubectl delete pod data-pod -n cka-labs

# Immediately create new pod using same PVC
kubectl apply -f manifests/pod-with-pvc.yaml

# Check file still exists!
kubectl exec data-pod -n cka-labs -- cat /data/file.txt
# Output: Persistent data (survived pod deletion!)
```

---

## ✅ Lab 3: StorageClasses & Dynamic Provisioning

**Duration:** 25 minutes  
**Objective:** Understand dynamic volume provisioning

### Understanding StorageClass

StorageClass = Template for provisioning PV when PVC requested

Features:
- Dynamic provisioning (create volumes on-demand)
- Specify storage type, tier, parameters
- Automatic PV creation when PVC created

### Step 1: Create Custom StorageClass

```yaml
# manifests/storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: premium-fast
provisioner: disk.csi.azure.com  # Azure disk provisioner
parameters:
  skuname: Premium_LRS
  kind: Managed
reclaimPolicy: Delete  # Delete PV when PVC deleted
allowVolumeExpansion: true  # Allow PVC resizing
```

```bash
kubectl apply -f manifests/storageclass.yaml

# View storage classes
kubectl get storageclass
```

### Step 2: Create PVC Using Custom StorageClass

```yaml
# manifests/pvc-premium.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: premium-pvc
  namespace: cka-labs
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: premium-fast  # Use our custom class
  resources:
    requests:
      storage: 10Gi
```

```bash
kubectl apply -f manifests/pvc-premium.yaml

# Watch PVC progress
kubectl get pvc premium-pvc -n cka-labs -w
# Pending -> Bound (PV auto-created)

# Check PV created
kubectl get pv
# Shows auto-created PV
```

### Step 3: Expand PVC (if allowed)

```bash
# Edit PVC to increase size
kubectl patch pvc premium-pvc -n cka-labs -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'

# Check size increased
kubectl get pvc premium-pvc -n cka-labs
```

---

## 🎯 Access Modes

```
ReadWriteOnce (RWO)  - Single pod read-write
ReadOnlyMany (ROM)   - Many pods read-only
ReadWriteMany (RWX)  - Many pods read-write

Note: Azure Disk = RWO only
      Azure Files = RWX available
```

---

## 📝 Common Storage Issues

**PVC stuck in Pending:**
```bash
# Check events
kubectl describe pvc <name> -n cka-labs

# Likely: No nodes available in zone, quota exceeded
# Solution: Verify node availability
```

**Pod can't mount PVC:**
```bash
# Check pod events
kubectl describe pod <name> -n cka-labs

# Common: Wrong accessMode (RWO but multi-pod)
```

---

## ✅ Lab Verification

- [ ] Created volumes with emptyDir, configMap, secret
- [ ] Created PVC from PV
- [ ] Used PVC in pod
- [ ] Verified data persistence across pod recreation
- [ ] Created custom StorageClass
- [ ] Used StorageClass for dynamic provisioning

---

**Next:** [Security Module](../security/README.md)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)
