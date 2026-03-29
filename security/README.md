# Security & RBAC Module

**Exam Weight:** 12%  
**Time Budget:** 14 minutes during exam

## Overview

Security in Kubernetes centers on access control (RBAC). This module covers authentication, authorization, and pod security policies.

## Topics Covered

1. **ServiceAccounts** - Pod identity
2. **RBAC** - Role-Based Access Control
3. **Roles & ClusterRoles** - Permission definitions
4. **RoleBindings & ClusterRoleBindings** - Assign roles
5. **Pod Security Policies** - Container security constraints
6. **Secrets & ConfigMaps** - Sensitive data management

---

## ✅ Lab 1: ServiceAccounts

**Duration:** 20 minutes  
**Objective:** Create and use service accounts

### Understanding ServiceAccounts

ServiceAccount = Identity for pods to use Kubernetes API

When pod starts, it gets mounted a token for authentication.

### Step 1: Create ServiceAccount

```bash
# Create service account
kubectl create serviceaccount developer -n cka-labs

# List service accounts
kubectl get serviceaccount -n cka-labs

# View details
kubectl describe sa developer -n cka-labs
```

### Step 2: Examine ServiceAccount Token

```bash
# ServiceAccount auto-creates Secret with token
kubectl get secrets -n cka-labs | grep developer

# View token (sensitive!)
kubectl get secret <secret-name> -n cka-labs -o jsonpath='{.data.token}' | base64 -d
```

### Step 3: Use ServiceAccount in Pod

```yaml
# manifests/pod-with-sa.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-demo-pod
  namespace: cka-labs
spec:
  serviceAccountName: developer  # Use our service account
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
```

```bash
kubectl apply -f manifests/pod-with-sa.yaml

# Check SA mounted
kubectl exec sa-demo-pod -n cka-labs -- ls /var/run/secrets/kubernetes.io/serviceaccount/
# Shows: ca.crt, namespace, token
```

---

## ✅ Lab 2: RBAC - Roles & RoleBindings

**Duration:** 30 minutes  
**Objective:** Control what pods/users can do

### Understanding RBAC

Three main RBAC objects:
- **Role** - What can be done (namespace-scoped)
- **ClusterRole** - What can be done (cluster-scoped)
- **RoleBinding** - Assign role to user/SA (namespace-scoped)
- **ClusterRoleBinding** - Assign role to user/SA (cluster-scoped)

### Step 1: Create Role

```yaml
# manifests/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: cka-labs
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

```bash
kubectl apply -f manifests/role.yaml

# View role
kubectl get role -n cka-labs
kubectl describe role pod-reader -n cka-labs
```

### Step 2: Create RoleBinding

```yaml
# manifests/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: cka-labs
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
- kind: ServiceAccount
  name: developer
  namespace: cka-labs
```

```bash
kubectl apply -f manifests/rolebinding.yaml

# View rolebinding
kubectl get rolebinding -n cka-labs
```

### Step 3: Test Permissions

```bash
# Check if service account has permissions
kubectl auth can-i get pods \
  --as=system:serviceaccount:cka-labs:developer \
  --namespace=cka-labs
# Output: yes

# Check if can delete pods (not granted)
kubectl auth can-i delete pods \
  --as=system:serviceaccount:cka-labs:developer \
  --namespace=cka-labs
# Output: no
```

### Step 4: Create More Permissions

```yaml
# manifests/role-extended.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-manager
  namespace: cka-labs
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch", "create", "delete", "update", "patch"]
```

```bash
kubectl apply -f manifests/role-extended.yaml

# Bind to different SA
kubectl create rolebinding manage-pods \
  --role=pod-manager \
  --serviceaccount=cka-labs:developer \
  -n cka-labs
```

---

## ✅ Lab 3: ClusterRoles (Cluster-wide Access)

**Duration:** 25 minutes  
**Objective:** Grant cluster-wide permissions

### ClusterRole vs Role

- **Role** - Permission within ONE namespace
- **ClusterRole** - Permission across ALL namespaces

### Step 1: Create ClusterRole

```yaml
# manifests/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-reader
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
```

```bash
kubectl apply -f manifests/clusterrole.yaml

# View cluster roles
kubectl get clusterrole | grep node-reader
```

### Step 2: Create ClusterRoleBinding

```yaml
# manifests/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-nodes
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: node-reader
subjects:
- kind: ServiceAccount
  name: developer
  namespace: cka-labs
```

```bash
kubectl apply -f manifests/clusterrolebinding.yaml

# Test - SA can now read nodes from ANY namespace
kubectl auth can-i get nodes \
  --as=system:serviceaccount:cka-labs:developer
# Output: yes
```

---

## ✅ Lab 4: Pod Security Policies

**Duration:** 25 minutes  
**Objective:** Enforce security constraints on pods

### Understanding Pod Security

Pod Security Policy (PSP) / Pod Security Standards = Enforce security rules

Examples:
- Must run as non-root user
- Can't use privileged containers
- Must have resource limits
- Filesystem must be read-only

### Step 1: Create Pod Security Policy

```yaml
# manifests/podsecuritypolicy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
  - ALL
  volumes:
  - 'configMap'
  - 'emptyDir'
  - 'projected'
  - 'secret'
  - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'MustRunAs'
    seLinuxOptions:
      level: "s0:c123,c456"
  fsGroup:
    rule: 'MustRunAs'
    ranges:
    - min: 2000
      max: 65535
  readOnlyRootFilesystem: false
```

```bash
kubectl apply -f manifests/podsecuritypolicy.yaml

# View PSP
kubectl get psp
```

### Step 2: Create Role to Use PSP

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: use-restricted-psp
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames: ['restricted']
```

```bash
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: use-restricted-psp
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames: ['restricted']
EOF

# Bind to service account
kubectl create clusterrolebinding developer-use-psp \
  --clusterrole=use-restricted-psp \
  --serviceaccount=cka-labs:developer
```

---

## ✅ Lab 5: Secrets & ConfigMaps

**Duration:** 20 minutes  
**Objective:** Store sensitive data safely

### ConfigMaps = Non-sensitive config  
### Secrets = Sensitive data (passwords, keys, etc.)

### Step 1: Create ConfigMap

```bash
# Create from literal values
kubectl create configmap db-config \
  --from-literal=DB_HOST=localhost \
  --from-literal=DB_PORT=5432 \
  -n cka-labs

# View
kubectl get configmap db-config -n cka-labs -o yaml
```

### Step 2: Create Secret

```bash
# Create from literal values
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=secretpass123 \
  -n cka-labs

# View (base64 encoded)
kubectl get secret db-creds -n cka-labs -o yaml

# Decode secret
kubectl get secret db-creds -n cka-labs -o jsonpath='{.data.password}' | base64 -d
# Output: secretpass123
```

### Step 3: Use in Pod Environment

```yaml
# manifests/pod-with-secrets.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-config
  namespace: cka-labs
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo $DB_HOST; echo $DB_USER; sleep 3600']
    
    env:
    # ConfigMap as env vars
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: db-config
          key: DB_HOST
    
    # Secret as env vars
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-creds
          key: username
```

```bash
kubectl apply -f manifests/pod-with-secrets.yaml

# Check env vars loaded
kubectl exec app-with-config -n cka-labs -- env | grep DB
```

---

## 🎯 RBAC Quick Reference

```bash
# Create role (grant permissions)
kubectl create role <role> \
  --verb=get,list,create \
  --resource=pods,services \
  -n <namespace>

# Create rolebinding (assign role to user/SA)
kubectl create rolebinding <binding> \
  --role=<role> \
  --serviceaccount=<namespace>:<sa> \
  -n <namespace>

# Check permissions
kubectl auth can-i <verb> <resource> \
  --as=system:serviceaccount:<ns>:<sa> \
  -n <namespace>
```

---

## ✅ Lab Verification

- [ ] Created and used ServiceAccounts
- [ ] Created Role and RoleBinding
- [ ] Created ClusterRole and ClusterRoleBinding
- [ ] Tested RBAC permissions with auth can-i
- [ ] Created Pod Security Policy
- [ ] Created and used ConfigMaps
- [ ] Created and used Secrets

---

**Next:** [Troubleshooting Module](../troubleshooting/README.md)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)
