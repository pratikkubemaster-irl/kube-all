# Networking Module

**Exam Weight:** 20% (Second highest - PRIORITY!)  
**Time Budget:** 24 minutes during exam

## Overview

Networking is critical for the CKA exam. This module covers Services, Ingress, DNS, and Network Policies - how applications communicate in Kubernetes.

## Topics Covered

1. **Services** - Expose apps (ClusterIP, NodePort, LoadBalancer)
2. **Ingress** - HTTP/HTTPS routing and SSL termination
3. **DNS** - Service discovery and naming
4. **Network Policies** - Control traffic between pods
5. **Troubleshooting** - Debug connectivity issues

---

## ✅ Lab 1: Services

**Duration:** 30 minutes  
**Objective:** Expose deployments using different Service types

### Understanding Services

Service = Stable endpoint for accessing pods (pods are ephemeral!)

**Three main types:**
- **ClusterIP** - Internal cluster access only (default)
- **NodePort** - External access via node IP + port
- **LoadBalancer** - Cloud LB endpoint (AWS/Azure)

### Step 1: Create Deployment

```bash
# Create deployment to expose
kubectl create deployment web --image=nginx --replicas=3 -n cka-labs

# Verify pods running
kubectl get pods -n cka-labs
```

### Step 2: Expose as ClusterIP (Internal)

```bash
# Create ClusterIP service (default)
kubectl expose deployment web --type=ClusterIP --port=80 -n cka-labs

# View service
kubectl get svc -n cka-labs
kubectl describe svc web -n cka-labs
```

```bash
# Test from inside cluster
# Create debug pod to test connectivity
kubectl run -it --rm debug --image=busybox -n cka-labs -- sh

# Inside debug pod:
wget -O- http://web:80     # Use service name in DNS
# OR with FQDN:
wget -O- http://web.cka-labs.svc.cluster.local:80
# Should return nginx HTML
exit
```

### Step 3: Expose as NodePort (External)

```bash
# Create NodePort service
kubectl expose deployment web --type=NodePort --port=80 --name=web-nodeport -n cka-labs

# Get assigned port
kubectl get svc web-nodeport -n cka-labs

# Note: HIGH PORT number (30000-32767)
# Example: Port 80 -> NodePort 30234

# Access from outside cluster
# Get node IP
kubectl get nodes -o wide

# Visit: http://<node-ip>:30234
```

### Step 4: Expose as LoadBalancer

```bash
# Create LoadBalancer service (on public clouds)
kubectl expose deployment web --type=LoadBalancer --port=80 --name=web-lb -n cka-labs

# Check external IP
kubectl get svc web-lb -n cka-labs
# EXTERNAL-IP will provision (may take 1-2 mins on Azure)

# Once provisioned, access at external IP:80
```

### Step 5: Service Selectors

Services find pods using **labels and selectors**:

```bash
# Service uses selector to find matching pods
kubectl get svc web -n cka-labs -o yaml | grep -A3 "selector:"

# Pods with matching labels receive traffic
kubectl get pods -n cka-labs --show-labels | grep "app=web"
```

---

## ✅ Lab 2: Ingress

**Duration:** 30 minutes  
**Objective:** Configure HTTP(S) routing with Ingress

### Understanding Ingress

Ingress = HTTP/HTTPS routing layer (Layer 7)

Like a reverse proxy that routes based on hostname, path, TLS, etc.

### Step 1: Deploy Ingress Controller (if not present)

Check if ingress controller running:

```bash
kubectl get deployments -n ingress-nginx
# OR
kubectl get deployments -n ingress-controller
```

If not present (on AKS, might be AGIC):

```bash
# For testing, create simple ingress anyway
# AKS might have built-in ingress or need AGIC setup
```

### Step 2: Create Ingress Resource

```yaml
# manifests/ingress-example.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: cka-labs
spec:
  rules:
  - host: web.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
```

```bash
kubectl apply -f manifests/ingress-example.yaml

# View ingress
kubectl get ingress -n cka-labs
kubectl describe ingress web-ingress -n cka-labs
```

### Step 3: Test Ingress (Local Testing)

```bash
# Forward ingress controller port locally
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80 &

# Test with custom host
curl -H "Host: web.example.com" http://localhost:8080
# Should return nginx HTML
```

---

## ✅ Lab 3: Network Policies

**Duration:** 25 minutes  
**Objective:** Control traffic between pods

### Understanding Network Policies

Network Policy = Firewall rules for pod-to-pod communication

By default: All pods can talk to all pods  
With Network Policy: Only allowed traffic flows

### Step 1: Create Two Deployments

```bash
# Frontend deployment
kubectl create deployment frontend --image=nginx -n cka-labs

# Backend deployment
kubectl create deployment backend --image=busybox -n cka-labs

# Expose both as services
kubectl expose deployment frontend --port=80 -n cka-labs
kubectl expose deployment backend --port=8080 -n cka-labs
```

### Step 2: Deny All Traffic (Default Deny)

```yaml
# manifests/networkpolicy-deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: cka-labs
spec:
  podSelector: {}  # Apply to all pods in namespace
  policyTypes:
  - Ingress
  - Egress
  # No rules = no traffic allowed!
```

```bash
kubectl apply -f manifests/networkpolicy-deny-all.yaml

# Now pods can't communicate at all
# Testing pods will timeout
```

### Step 3: Allow Specific Traffic

```yaml
# manifests/networkpolicy-allow.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: cka-labs
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

```bash
kubectl apply -f manifests/networkpolicy-allow.yaml

# Now frontend pods can talk to backend pods on port 8080
# But nothing else can
```

---

## ✅ Lab 4: DNS & Service Discovery

**Duration:** 20 minutes  
**Objective:** Understand Kubernetes DNS

### Understanding Kubernetes DNS

Kubernetes runs CoreDNS which automatically creates DNS records for:
- Services
- Pods (optional)

### Step 1: Check CoreDNS

```bash
# CoreDNS pods in kube-system
kubectl get pods -n kube-system | grep coredns

# CoreDNS service
kubectl get svc -n kube-system | grep kube-dns

# Should typically be named "kube-dns"
```

### Step 2: DNS Names for Services

```bash
# Service DNS naming convention:
# Short name (same namespace): servicename
# Full name (cross-namespace): servicename.namespace
# Full FQDN: servicename.namespace.svc.cluster.local

# Example: web service in cka-labs namespace can be accessed as:
# - web (from within cka-labs namespace)
# - web.cka-labs (from any namespace)
# - web.cka-labs.svc.cluster.local (full FQDN)
```

### Step 3: Test DNS Resolution

```bash
# Create debug pod
kubectl run -it --rm debug --image=busybox -n cka-labs -- sh

# Inside pod, test DNS
nslookup web                                    # Short name
nslookup web.cka-labs                          # Namespace qualified
nslookup web.cka-labs.svc.cluster.local        # Full FQDN
nslookup kube-dns.kube-system.svc.cluster.local # Cross-namespace

# All should resolve to service IP
```

### Step 4: Understand DNS Lookup Path

```
1. Pod tries: web
2. CoreDNS doesn't find it in pod's namespace
3. DNS resolver tries: web.cka-labs (with search domain)
4. Found! Returns ClusterIP of web service
```

---

## 📝 Quick Troubleshooting Checklist

**Can't access service?**
```bash
# 1. Check service exists
kubectl get svc -n cka-labs

# 2. Check pods exist (behind service)
kubectl get pods -n cka-labs --show-labels

# 3. Check labels match selector
kubectl describe svc web -n cka-labs

# 4. Check DNS resolution
kubectl run -it --rm debug --image=busybox -- nslookup web.cka-labs

# 5. Check pod is listening
kubectl exec <pod> -- netstat -tlnp

# 6. Check NetworkPolicy allows traffic
kubectl get networkpolicy -n cka-labs
```

---

## 🎯 Quick Reference

| Resource | Purpose | External Access? |
|----------|---------|------------------|
| ClusterIP | Internal pod communication | No |
| NodePort | Access via node IP:port | Yes, limited |
| LoadBalancer | Cloud LB endpoint | Yes, full |
| Ingress | HTTP(S) routing | Yes, advanced |
| NetworkPolicy | Pod firewall rules | N/A |

---

## ✅ Lab Verification

- [ ] Created ClusterIP, NodePort, LoadBalancer services
- [ ] Tested service connectivity
- [ ] Configured and tested Ingress
- [ ] Created and tested Network Policies
- [ ] Tested DNS resolution
- [ ] Debugged connectivity issues

---

**Next:** [Storage Module](../storage/README.md)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)
