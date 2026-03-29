# Workloads & APIs Module

**Exam Weight:** 15%  
**Time Budget:** 18 minutes during exam

## Overview

Workloads are the core of Kubernetes - they're the applications running in your cluster. This module covers all resource types for running workloads and how to manage their lifecycle.

## Topics Covered

1. **Pods** - Smallest deployable unit
2. **Deployments** - Stateless applications with updates
3. **StatefulSets** - Stateful applications with persistent identity
4. **DaemonSets** - Run on every (or specific) node
5. **Jobs & CronJobs** - One-time and scheduled tasks
6. **ConfigMaps & Secrets** - Store configuration and sensitive data

## 📚 Quick Reference

| Resource | Use Case | Replicas | Pod Names |
|----------|----------|----------|-----------|
| Pod | Testing, single instance | 1 | Random |
| Deployment | Stateless apps, web servers | Many | Random |
| StatefulSet | Databases, stateful apps | Many | Predictable (ordered) |
| DaemonSet | Node agents, logging | Per node | One per node |
| Job | One-time tasks | 1+ | Temporary |
| CronJob | Scheduled tasks | As scheduled | Temporary |

---

## ✅ Lab 1: Pods

**Duration:** 15 minutes  
**Objective:** Create and manage basic pods

### Step 1: Create a Pod Imperatively

```bash
# Quick way to create a pod (imperative)
kubectl run nginx --image=nginx -n cka-labs

# Verify pod is running
kubectl get pods -n cka-labs
kubectl describe pod nginx -n cka-labs
```

### Step 2: Create Pod from Manifest

Save this as `manifests/pod-example.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
  namespace: cka-labs
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
  - name: busybox
    image: busybox
    command: ['sh', '-c', 'echo "Hello from busybox" && sleep 3600']
```

```bash
# Create pod from manifest
kubectl apply -f manifests/pod-example.yaml

# View details
kubectl get pod multi-container-pod -n cka-labs -o yaml
```

### Step 3: Execute Commands in Pod

```bash
# Get shell access to pod
kubectl exec -it nginx -n cka-labs -- /bin/sh

# Inside pod:
curl localhost:80   # Should return nginx HTML
exit

# From outside: Run single command
kubectl exec nginx -n cka-labs -- nginx -v
```

### Step 4: View Logs

```bash
# View container logs
kubectl logs nginx -n cka-labs

# Follow logs (like tail -f)
kubectl logs -f nginx -n cka-labs

# Previous logs (from crashed container)
kubectl logs nginx -n cka-labs --previous
```

### Step 5: Delete Pod

```bash
# Delete pod
kubectl delete pod nginx -n cka-labs

# Verify deletion
kubectl get pods -n cka-labs
```

**Key Pod Facts:**
- Pods are ephemeral - don't use them for persistent data
- Multiple containers in a pod share networking (localhost)
- Pods are the smallest deployable unit (always inside higher resource)

---

## ✅ Lab 2: Deployments

**Duration:** 30 minutes  
**Objective:** Create, scale, and update deployments

### Step 1: Create Deployment

```bash
# Imperative way
kubectl create deployment web --image=nginx -n cka-labs

# OR declarative (save as manifests/deployment.yaml):

apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: cka-labs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f manifests/deployment.yaml
```

### Step 2: View Deployment Status

```bash
# See deployment
kubectl get deployment -n cka-labs

# Detailed view
kubectl describe deployment web -n cka-labs

# See pods created by deployment
kubectl get pods -n cka-labs

# All should be labeled app=web
kubectl get pods -n cka-labs --show-labels
```

### Step 3: Scale Deployment

```bash
# Scale to 5 replicas
kubectl scale deployment web --replicas=5 -n cka-labs

# Verify
kubectl get deployment web -n cka-labs  # Shows DESIRED: 5

# Or edit directly
kubectl edit deployment web -n cka-labs  # Change spec.replicas
```

### Step 4: Rolling Update

```bash
# Update image to newer version
kubectl set image deployment/web nginx=nginx:1.21 -n cka-labs

# Watch rollout progress
kubectl rollout status deployment/web -n cka-labs

# See rollout history
kubectl rollout history deployment/web -n cka-labs

# View specific revision
kubectl rollout history deployment/web -n cka-labs --revision=1
```

### Step 5: Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/web -n cka-labs

# Rollback to specific revision
kubectl rollout undo deployment/web -n cka-labs --to-revision=1

# Verify version changed back
kubectl get deployment web -n cka-labs -o yaml | grep -A3 "image:"
```

**Deployment Key Facts:**
- Manages rolling updates (gradual pod replacement)
- Maintains desired replica count
- Automatic pod restart if pod dies
- Can rollback to any previous version

---

## ✅ Lab 3: StatefulSets

**Duration:** 30 minutes  
**Objective:** Deploy stateful applications with persistent identity

StatefulSets are like Deployments but with:
- **Predictable pod names** (mysql-0, mysql-1, not random)
- **Persistent storage** per pod
- **Ordered scaling** (scale up 0→1→2, scale down 2→1→0)

### Step 1: Create Headless Service (Required for StatefulSet!)

StatefulSets MUST have a headless service:

```yaml
# manifests/mysql-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: cka-labs
spec:
  clusterIP: None  # <-- Make it headless!
  ports:
  - port: 3306
    targetPort: 3306
  selector:
    app: mysql
```

```bash
kubectl apply -f manifests/mysql-service.yaml
```

###Step 2: Create StatefulSet

```yaml
# manifests/mysql-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: cka-labs
spec:
  serviceName: mysql  # <-- Reference headless service!
  replicas: 3
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
          value: "secret"
        volumeMounts:
        - name: datadir
          mountPath: /var/lib/mysql
  volumeClaimTemplates:  # <-- Creates PVC for each pod!
  - metadata:
      name: datadir
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: default  # Use AKS default
      resources:
        requests:
          storage: 10Gi
```

```bash
kubectl apply -f manifests/mysql-statefulset.yaml

# Watch pods start IN ORDER
kubectl get pods -n cka-labs -w
# mysql-0 starts and runs
# Only after mysql-0 ready does mysql-1 start
# Then mysql-2
```

### Step 3: Verify StatefulSet Properties

```bash
# Pods have predictable names
kubectl get pods -n cka-labs  # See mysql-0, mysql-1, mysql-2

# Each pod has its own PVC
kubectl get pvc -n cka-labs
# Shows 3 PVCs: datadir-mysql-0, datadir-mysql-1, datadir-mysql-2

# DNS is stable
# Inside any pod:
kubectl exec mysql-0 -c mysql -n cka-labs -- hostname
# Output: mysql-0

# Each pod has stable DNS name
# mysql-0.mysql.cka-labs.svc.cluster.local always resolves to mysql-0
```

### Step 4: Scale StatefulSet

```bash
# Scale up - pods start in order
kubectl scale statefulset mysql --replicas=5 -n cka-labs

# Watch scaling
kubectl get pods -n cka-labs -w

# Scale down - pods terminate in REVERSE order
# mysql-4, then 3, then 2 (keeps ordinals low)
kubectl scale statefulset mysql --replicas=2 -n cka-labs
```

**StatefulSet Key Facts:**
- Requires headless Service (clusterIP: None)
- Pod names predictable and ordered (app-0, app-1, app-2)
- Each pod gets stable DNS name
- Persistent storage per pod (volumeClaimTemplates)
- Used for: MySQL, PostgreSQL, Redis, Elasticsearch, etc.

---

## ✅ Lab 4: DaemonSets & Jobs

**Duration:** 30 minutes  
**Objective:** Run pods on all nodes and run one-time tasks

### Lab 4A: DaemonSet

DaemonSet ensures pod runs on **every (or specified) node**:

```yaml
# manifests/daemonset-example.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-monitor
  namespace: cka-labs
spec:
  selector:
    matchLabels:
      app: monitor
  template:
    metadata:
      labels:
        app: monitor
    spec:
      containers:
      - name: monitor
        image: busybox
        command: ['sh', '-c', 'while true; do echo "Monitoring from $(hostname)"; sleep 30; done']
```

```bash
kubectl apply -f manifests/daemonset-example.yaml

# One pod per node
kubectl get pods -n cka-labs -o wide | grep node-monitor

# Count should equal node count unless you used nodeSelector

# Describe to see details
kubectl describe daemonset node-monitor -n cka-labs
```

**DaemonSet Use Cases:** Logging agents, monitoring agents, network plugins

### Lab 4B: Job

Job runs task to completion:

```yaml
# manifests/job-example.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
  namespace: cka-labs
spec:
  completions: 5  # Run 5 times
  parallelism: 2  # Run 2 in parallel
  template:
    spec:
      containers:
      - name: processor
        image: busybox
        command: ['sh', '-c', 'echo "Processing data..." && sleep 5 && echo "Done!"']
      restartPolicy: Never  # Jobs can't use Always
```

```bash
kubectl apply -f manifests/job-example.yaml

# Watch job progress
kubectl get job -n cka-labs -w

# See job pods
kubectl get pods -n cka-labs  # Shows data-processor-xxxx pods

# View job logs
kubectl logs -n cka-labs --selector=job-name=data-processor

# When done, job keeps completed pods (for log inspection)
kubectl get pods -n cka-labs  # Pods stay even after completion
```

### Lab 4C: CronJob

CronJob runs Job on schedule:

```yaml
# manifests/cronjob-example.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-backup
  namespace: cka-labs
spec:
  schedule: "0 2 * * *"  # 2 AM daily (cron syntax)
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: busybox
            command: ['sh', '-c', 'echo "Backup at $(date)" >> /tmp/backup.log']
          restartPolicy: OnFailure
```

```bash
kubectl apply -f manifests/cronjob-example.yaml

# See cronjob
kubectl get cronjob -n cka-labs

# Check scheduled jobs (won't run until schedule time!)
kubectl get jobs -n cka-labs --sort-by=.metadata.creationTimestamp
```

---

## 📝 Deployment Manifests

Create `manifests/` directory and save examples above there for reuse.

---

## 🎯 Quick Comparison

| Resource | When to Use | Pod Naming | Storage |
|----------|-----------|-----------|---------|
| Pod | Testing, single tasks | Random | Ephemeral |
| Deployment | Web apps, stateless | Random | Ephemeral |
| StatefulSet | Databases, caches | Ordered (mysql-0,1,2) | Persistent PVC |
| DaemonSet | Logging, monitoring | One per node | Ephemeral |
| Job | Batch processing | Random, auto-clean | Ephemeral |
| CronJob | Scheduled tasks | Random per run | Ephemeral |

---

## ✅ Lab Verification Checklist

- [ ] Created and managed pods
- [ ] Deployed multi-replica deployment
- [ ] Scaled deployment up/down
- [ ] Performed rolling update
- [ ] Rolled back deployment
- [ ] Created StatefulSet with persistent storage
- [ ] Verified StatefulSet pod ordering
- [ ] Created DaemonSet
- [ ] Created and monitored Job
- [ ] Created CronJob

---

**Next:** [Scheduling Module](../scheduling/README.md)  
**Track Progress:** [PROGRESS_TRACKER.md](../PROGRESS_TRACKER.md)
