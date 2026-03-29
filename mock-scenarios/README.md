# Mock Exam Scenarios

**Purpose:** Simulate real CKA exam conditions and test integrated knowledge

These are realistic, multi-concept scenarios that combine skills from multiple modules. Do these under time pressure (90 minutes each) to practice pacing.

---

## 📋 Scenario 1: Deploy a Multi-Tier Application

**Time Limit:** 90 minutes  
**Concepts:** Deployments, Services, ConfigMaps, Secrets, Networking

### Scenario

You have a simple web application with:
- Frontend (nginx) - 3 replicas
- Backend API (Python app) - 2 replicas
- Database (MySQL) - 1 replica with persistent storage

Requirements:
1. Frontend should be accessible externally via NodePort or LoadBalancer
2. Frontend and backend communicate internally (service DNS)
3. Backend connects to database with credentials stored securely
4. All components in namespace: `multi-tier`
5. Frontend should be labeled `tier=frontend`, backend `tier=backend`
6. Database must survive pod restarts

### Tasks

```yaml
# Task 1: Create namespace
kubectl create namespace multi-tier

# Task 2: Create ConfigMap for backend configuration
kubectl create configmap api-config \
  --from-literal=DB_HOST=mysql \
  --from-literal=DB_PORT=3306 \
  -n multi-tier

# Task 3: Create Secret for database credentials
kubectl create secret generic db-creds \
  --from-literal=root_password=admin123 \
  -n multi-tier

# Task 4: Create MySQL StatefulSet with persistent storage
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: multi-tier
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
  - port: 3306
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: multi-tier
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-creds
              key: root_password
        volumeMounts:
        - name: data
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: default
      resources:
        requests:
          storage: 5Gi

# Task 5: Create Backend Deployment
kubectl create deployment backend --image=busybox -n multi-tier
# Edit to use ConfigMap env vars
# Add command: sleep 3600

# Task 6: Create Frontend Deployment
kubectl create deployment frontend --image=nginx --replicas=3 -n multi-tier

# Task 7: Expose Frontend externally
kubectl expose deployment frontend --type=NodePort --port=80 -n multi-tier

# Task 8: Expose Backend for internal communication
kubectl expose deployment backend --port=8080 --target-port=8080 -n multi-tier
```

### Verification

```bash
# Verify all components running
kubectl get all -n multi-tier

# Verify labels
kubectl get pods -n multi-tier --show-labels | grep tier

# Verify services can reach each other
kubectl run -it --rm debug --image=busybox -n multi-tier -- nslookup backend

# Verify frontend accessible externally
curl http://<node-ip>:<nodeport>

# Verify database persistent storage
kubectl get pvc -n multi-tier
```

---

## 📋 Scenario 2: RBAC and Security Lockdown

**Time Limit:** 90 minutes  
**Concepts:** RBAC, ServiceAccounts, Pod Security, Network Policies

### Scenario

Your cluster needs security hardening:
- Developer team needs read-only access to pods in `dev` namespace
- Dev team can't access production namespace
- Production apps can only be deployed by admins
- pods should not run as root
- pods can't make external connections

### Tasks

```bash
# Task 1: Create dev and prod namespaces
kubectl create namespace dev
kubectl create namespace prod

# Task 2: Create ServiceAccount for developers
kubectl create serviceaccount dev-user -n dev

# Task 3: Create Role with read-only pod access
kubectl create role pod-reader \
  --verb=get,list,watch \
  --resource=pods \
  -n dev

# Task 4: Bind role to service account
kubectl create rolebinding read-pods \
  --role=pod-reader \
  --serviceaccount=dev:dev-user \
  -n dev

# Task 5: Verify permissions (can read, not delete)
kubectl auth can-i get pods \
  --as=system:serviceaccount:dev:dev-user \
  --namespace=dev  # Should be: yes

kubectl auth can-i delete pods \
  --as=system:serviceaccount:dev:dev-user \
  --namespace=dev  # Should be: no

# Task 6: Create NetworkPolicy to deny all outbound traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: prod
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress: [] # No rules = nothing allowed

# Task 7: Deploy pod that respects security policy
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: prod
  labels:
    app: secure
spec:
  serviceAccountName: dev-user
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: busybox
    command: ['sleep', '3600']
    securityContext:
      readOnlyRootFilesystem: true
```

### Verification

```bash
# Verify RBAC works
kubectl get rolebinding -n dev

# Verify network policy
kubectl get networkpolicy -n prod

# Verify dev user access
kubectl get pods -n dev --as=system:serviceaccount:dev:dev-user
```

---

## 📋 Scenario 3: Troubleshooting Complex Problems

**Time Limit:** 90 minutes  
**Concepts:** All - requires diagnosis and fixing combined issues

### Scenario

Multiple things are broken on a cluster. Your job: identify and fix all issues.

**Setup (Intentionally Broken):**

```bash
# Issue 1: Wrong image tag
kubectl create deployment broken-image \
  --image=nginx:wrong-tag \
  -n cka-labs

# Issue 2: Service selector mismatch
kubectl create deployment backend --image=busybox -n cka-labs
kubectl expose deployment backend --port=8080 -n cka-labs
kubectl patch svc backend -p '{"spec":{"selector":{"app":"wrong"}}}'

# Issue 3: Pod pending (resource limit too high)
kubectl create pod resource-hog --image=ubuntu -n cka-labs \
  -o yaml --dry-run=client | \
  sed 's/containers:/containers:\n      - name: app\n        resources:\n          requests:\n            cpu: "100"\n            memory: "1000Gi"/' | \
  kubectl apply -f -

# Issue 4: CrashLoopBackOff
kubectl create pod crashing --image=busybox --command -- sh -c "exit 1" -n cka-labs
```

### Tasks

```bash
# Task 1: Find all failing pods
kubectl get pods -n cka-labs  # Identify broken ones

# Task 2: Fix broken-image (wrong tag)
# DEBUG:
kubectl describe pod broken-image-xxx -n cka-labs  # States: ImagePullBackOff
kubectl logs broken-image-xxx -n cka-labs  # Shows pull failure

# FIX:
kubectl set image deployment/broken-image nginx=nginx:latest -n cka-labs

# Task 3: Fix backend service connectivity
# DEBUG:
kubectl describe svc backend -n cka-labs  # Shows: Selector: app=wrong
kubectl get pods -n cka-labs --show-labels  # backend pods have app=backend

# FIX:
kubectl patch svc backend -p '{"spec":{"selector":{"app":"backend"}}}' -n cka-labs

# Task 4: Fix resource-hog pod
# DEBUG:
kubectl describe pod resource-hog -n cka-labs  # Pending state

# FIX:
kubectl delete pod resource-hog -n cka-labs
# Recreate with reasonable resources

# Task 5: Fix crashing pod
# DEBUG:
kubectl logs crashing -n cka-labs  # No output (exits immediately)
kubectl describe pod crashing -n cka-labs  # CrashLoopBackOff

# FIX:
kubectl delete pod crashing -n cka-labs
# Recreate with working command
kubectl create pod working --image=busybox -n cka-labs -- sleep 3600
```

### Verification

```bash
# All pods should be Running
kubectl get pods -n cka-labs

# Service should have endpoints
kubectl describe svc backend -n cka-labs  # Should show Endpoints: 10.x.x.x
```

---

## 📋 Scenario 4: Cluster Upgrade & Maintenance

**Time Limit:** 90 minutes  
**Concepts:** Cluster maintenance, node operations, backup/restore

### Scenario

You need to perform cluster maintenance:
- Upgrade kubelet on nodes
- Perform etcd backup
- Handle node draining
- Verify cluster health post-upgrade

### Tasks

```bash
# Task 1: Backup etcd (if self-managed cluster)
# (Skip for managed AKS - would be admin operation)

# Task 2: Get current cluster version
kubectl version --short
kubeadm version

# Task 3: Drain node before maintenance
kubectl get nodes  # Identify a node
kubectl drain <node-name> --ignore-daemonsets

# Task 4: Simulate node upgrade (would be software update in real scenario)
# Step: Run some command on node or wait 30 seconds

# Task 5: Uncordon node after upgrade
kubectl uncordon <node-name>

# Task 6: Verify cluster health
kubectl get nodes  # Should show Ready
kubectl get pods -A  # All should be Running/Completed
kubectl cluster-info  # Should work
```

### Verification

```bash
# All nodes Ready
kubectl get nodes

# All critical pods running
kubectl get pods -n kube-system | grep -E "apiserver|scheduler|controller|etcd"

# Check component status
kubectl get componentstatus
```

---

## 🏁 How to Use These Scenarios

### First Attempt (Learning)
1. Read scenario title
2. Set timer for 90 mins
3. DON'T look at solution
4. Work through tasks
5. If stuck after 10 mins, review relevant module
6. **Finish even if incomplete** - learning occurs in struggle

### After Completion
1. Stop timer - note total time
2. Verify all requirements met
3. Review what went wrong
4. Check my solutions (above)
5. Understand difference between yourresult and expected

### Second Attempt (Performance)
1. Choose different scenario
2. Set timer for 90 mins
3. Try to finish in 60-70 mins
4. Verify solution
5. Track time improvement

---

## 📊 Passing Scores Target

For each scenario:
- **100% tasks complete** = Exam ready
- **80% tasks complete** = Good, but more practice
- **60% tasks complete** = Review modules needed
- **<60% tasks complete** = Study more before exam

---

## 💡 Pro Tips for Mock Exams

1. **Read ALL requirements first** (5 mins)
2. **Start with easy tasks** (build confidence)
3. **Come back to hard tasks** (save for last)
4. **Verify after each task** (don't assume success)
5. **Leave 10 mins for review** (catch mistakes)
6. **Time pressure matters** - go under 80 mins if possible

---

**Next:** [Prepare for Exam Day!](../STUDY_GUIDE.md#exam-day-checklist)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)

Good luck! Remember - you can do harder things than passing a test. 💪
