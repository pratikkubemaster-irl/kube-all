# Troubleshooting Module

**Exam Weight:** 13% (CRITICAL - includes performance debugging)  
**Time Budget:** 15 minutes during exam

## Overview

Troubleshooting tests your ability to diagnose and fix problems. This is a hands-on, practical skill tested heavily on CKA exams.

## Common Issues Covered

1. **Pod Issues** - Won't start, crashing, not responding
2. **Service Issues** - Can't connect, DNS problems
3. **Node Issues** - Node not ready, resource exhaustion
4. **Cluster Issues** - Control plane problems
5. **Storage Issues** - PVC pending, mounting fails
6. **Network Issues** - Connectivity, network policies

---

## ✅ Lab 1: Debug Pod Issues

**Duration:** 25 minutes  
**Objective:** Diagnose common pod failures

### Lab 1A: Pod Won't Start (ImagePullBackOff)

```yaml
# manifests/broken-pod-1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: broken-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: nonexistent-image:latest  # Wrong image!
```

```bash
kubectl apply -f manifests/broken-pod-1.yaml

# Check status
kubectl get pods -n cka-labs  # Shows: ImagePullBackOff
kubectl describe pod broken-pod -n cka-labs
# Events section shows: "image can't be pulled"

# Fix: Use real image
kubectl delete pod broken-pod -n cka-labs
# Edit YAML to use: image: nginx:latest
kubectl apply -f manifests/broken-pod-1.yaml
```

### Lab 1B: Pod Crashes (CrashLoopBackOff)

```yaml
# manifests/broken-pod-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: crashing-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'exit 0']  # Exits immediately!
```

```bash
kubectl apply -f manifests/broken-pod-2.yaml

# Check status
kubectl get pods -n cka-labs  # Shows: CrashLoopBackOff

# View logs (VERY IMPORTANT!)
kubectl logs crashing-pod -n cka-labs
# If log is empty, process exited immediately

# Check previous logs
kubectl logs crashing-pod -n cka-labs --previous
```

**Debugging Steps:**
```bash
# 1. Check pod status
kubectl get pod crashing-pod -n cka-labs

# 2. Describe pod (shows why it's failing)
kubectl describe pod crashing-pod -n cka-labs

# 3. Check logs
kubectl logs crashing-pod -n cka-labs

# 4. Check previous logs (if restarted)
kubectl logs crashing-pod -n cka-labs --previous

# 5. Check container restart count
kubectl get pod crashing-pod -n cka-labs -o yaml | grep restartCount
```

### Lab 1C: Pod Pending (Can't Schedule)

```yaml
# manifests/broken-pod-3.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pending-pod
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: "100"  # 100 CPUs - impossible!
        memory: "1000Gi"
```

```bash
kubectl apply -f manifests/broken-pod-3.yaml

# Pod stays Pending - can't be scheduled
kubectl describe pod pending-pod -n cka-labs
# Events show: "Insufficient cpu", "Insufficient memory"

# Fix: Reduce resource requests
# Change to reasonable values: cpu: "100m", memory: "128Mi"
```

---

## ✅ Lab 2: Debug Service Issues

**Duration:** 25 minutes  
**Objective:** Diagnose connectivity problems

### Lab 2A: Service Can't Route Traffic

```bash
# Create deployment
kubectl create deployment web --image=nginx --replicas=2 -n cka-labs

# Create service with WRONG selector
kubectl create service clusterip web-service --tcp=80:80 -n cka-labs

# Edit service to have wrong label
kubectl patch svc web-service -n cka-labs -p '{"spec":{"selector":{"app":"wrong"}}}'

# Now traffic won't route (selector doesn't match pods)
```

```bash
# Debugging:
# 1. Check service selector
kubectl describe svc web-service -n cka-labs
# Shows: Selector: app=wrong

# 2. Check if pods match selector
kubectl get pods -n cka-labs --show-labels
# Pods have: app=web (not "wrong"!)

# Fix: Correct selector
kubectl patch svc web-service -n cka-labs -p '{"spec":{"selector":{"app":"web"}}}'

# Now endpoints should be populated
kubectl describe svc web-service -n cka-labs
# Shows: Endpoints: 10.x.x.x:80, 10.x.x.x:80
```

### Lab 2B: Service DNS Not Resolving

```bash
# Check both CoreDNS pod and Service are running
kubectl get pods -n kube-system | grep coredns
kubectl get svc -n kube-system | grep kube-dns

# Test DNS from inside pod
kubectl run -it --rm debug --image=busybox -n cka-labs -- sh

# Inside pod:
nslookup web-service      # Should resolve
nslookup web-service.cka-labs  # Should resolve

# If fails, check CoreDNS pod logs
kubectl logs -n kube-system -l k8s-app=kube-dns
```

### Lab 2C: Port Mismatch

```bash
# Service port != Pod target port

# Check service port and targetPort
kubectl describe svc web-service -n cka-labs

# Check what port container listens on
kubectl get deployment web -n cka-labs -o yaml | grep -A2 "containerPort:"

# They must match!
# If not: kubectl edit svc web-service  (fix targetPort)
```

---

## ✅ Lab 3: Debug Node Issues

**Duration:** 20 minutes  
**Objective:** Diagnose node problems

### Lab 3A: Node NotReady

```bash
# Check node status
kubectl get nodes

# If node shows NotReady:
kubectl describe node <node-name> | grep -A10 "Conditions:"

# Common reasons:
# - NotReady: Kubelet not running
# - MemoryPressure: Running out of memory
# - DiskPressure: Running out of disk

# Fix kubelet (example):
# SSH into node and:
sudo systemctl status kubelet
sudo systemctl restart kubelet
sudo systemctl logs kubelet  # Check logs
```

### Lab 3B: Node Resource Exhaustion

```bash
# Check node capacity
kubectl describe nodes <node> | grep -A5 "Capacity:"

# Check allocated resources
kubectl describe nodes <node> | grep -A10 "Allocated resources:"

# Check memory and disk usage
kubectl top nodes

# If node full, consider:
# - Add more nodes
# - Delete unused pods/PVCs
# - Reduce resource limits
```

### Lab 3C: Drain Node for Maintenance

```bash
# Before updates, drain node
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# This evicts pods to other nodes

# After maintenance, uncordon
kubectl uncordon <node>

# Node can accept pods again
```

---

## ✅ Lab 4: Debug Cluster Issues

**Duration:** 15 minutes  
**Objective:** Diagnose control plane problems

### Check Control Plane Components

```bash
# View component status
kubectl get componentstatus

# Or deprecated command:
kubectl get cs

# Should show all components Healthy:
# - controller-manager
# - scheduler
# - etcd
```

### Check Control Plane Pods

```bash
# Almost all control plane runs as pods
kubectl get pods -n kube-system

# If control plane pod missing/crashing:
# Check pod logs:
kubectl logs -n kube-system <pod-name> -c <container>

# Common issue: API server can't start (cert expired, config wrong)
```

### Check API Server

```bash
# Test API connectivity
kubectl cluster-info

# If API server unreachable:
# 1. Check pod status
kubectl get pods -n kube-system | grep apiserver

# 2. Check logs
kubectl logs -n kube-system -l component=kube-apiserver

# 3. Check certificates
kubeadm certs check-expiration
```

---

## ✅ Lab 5: Quick Debugging Checklist

Save this checklist and use during exam:

```bash
# POD ISSUES
kubectl get pods -n <ns>                             # Status
kubectl describe pod <pod> -n <ns>                  # Details + Events
kubectl logs <pod> -n <ns>                          # Container logs
kubectl logs <pod> -n <ns> --previous               # Previous run logs
kubectl exec -it <pod> -n <ns> -- /bin/sh          # Shell into pod

# SERVICE ISSUES
kubectl describe svc <svc> -n <ns>                  # Check selector + endpoints
kubectl get endpoints <svc> -n <ns>                 # Check endpoints populated
kubectl run -it --rm debug --image=busybox -- nslookup <svc>  # DNS
kubectl port-forward svc/<svc> 8080:80 -n <ns>     # Port forward

# NODE ISSUES
kubectl describe node <node>                        # Check conditions
kubectl top nodes                                   # Resource usage
kubectl cordon <node>                               # Prevent scheduling
kubectl drain <node> --ignore-daemonsets            # Evict pods

# CLUSTER ISSUES
kubectl get componentstatus                         # Control plane
kubectl get events -n <ns>                          # Recent events
kubectl top pods -n <ns>                            # Pod resource usage

# GENERAL DEBUGGING
kubectl get all -n <ns>                             # All resources
kubectl api-resources                               # Valid resource types
kubectl explain <resource>.spec                     # Field documentation
```

---

## 🎯 Common Error Messages

```
ImagePullBackOff          → Wrong image name or not in registry
CrashLoopBackOff          → Container crashes, check logs
Pending                   → Can't schedule (resource limit or node selector)
ErrImagePull              → Image doesn't exist
ImageInspectError         → Image can't be pulled
CreateContainerError      → Volume mount or config wrong
OOMKilled                 → Out of memory (increase limits)
Backoff restarting failed container → Process keeps crashing
```

---

## 📝 Real-World Troubleshooting Flow

```
1. Problem Reported
   ↓
2. Get Status (kubectl get, kubectl describe)
   ↓
3. Check Logs (kubectl logs, previous)
   ↓
4. Check Events (kubectl describe shows recent events)
   ↓
5. Check Related Resources (pod → service → node → cluster)
   ↓
6. Identify Root Cause
   ↓
7. Fix Configuration
   ↓
8. Verify Fix (pod runs, service routes, etc.)
```

---

## ✅ Lab Verification

- [ ] Debugged ImagePullBackOff pod
- [ ] Debugged CrashLoopBackOff pod
- [ ] Debugged Pending pod
- [ ] Debugged service routing issue
- [ ] Debugged DNS issue
- [ ] Debugged node issue
- [ ] Understood troubleshooting workflow

---

**Next:** [Mock Exam Scenarios](../mock-scenarios/)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)
