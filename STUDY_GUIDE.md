# CKA Exam Study & Reference Guide

Your complete reference for exam tips, command cheat sheets, and last-minute prep.

## ⏱️ Time Management Strategy

### Exam Format
- **Duration:** 2 hours (120 minutes)
- **Question Type:** Practical terminal-based tasks
- **Passing Score:** 66%
- **Tasks:** Usually 15-20 practical problems

### Recommended Time Allocation

| Domain | Weight | Time (mins) | Questions |
|--------|--------|-------------|-----------|
| Cluster Basics | 25% | 30 | 4-5 |
| Services/Networking | 20% | 24 | 3-4 |
| Troubleshooting | 13% | 15 | 2-3 |
| Security/RBAC | 12% | 14 | 2 |
| Workloads | 15% | 18 | 2-3 |
| Storage | 10% | 12 | 1-2 |
| Scheduling | 5% | 6 | 1 |

### During Exam Strategy

1. **First 5 mins (0:00-0:05)** - Read ALL questions quickly, mark difficulty
2. **Time Allocation (0:05-2:00)**
   - Start with quick/easy questions (cluster, workloads)
   - Build confidence early
   - Do high-weight items (cluster, networking) thoroughly
   - Leave troubleshooting for last (it requires thinking, not speed)
3. **Last 10 mins (1:50-2:00)**
   - Review high-value answers
   - Fix obvious mistakes
   - Mark incomplete tasks for scoring

---

## 🔥 Essential kubectl Commands

### Context & Cluster Info

```bash
# View current context
kubectl config current-context

# Switch context
kubectl config use-context <context-name>

# View all contexts
kubectl config get-contexts

# Get cluster info
kubectl cluster-info

# Get API resources (what you can create)
kubectl api-resources
```

### Resource Inspection

```bash
# Get resources with details
kubectl get pods -o wide
kubectl get nodes -o json
kubectl get all -n <namespace>

# Describe for detailed info
kubectl describe node <node-name>
kubectl describe pod <pod-name> -n <namespace>

# Watch for real-time changes
kubectl get pods -w
kubectl get pods --watch
```

### Creation & Modification

```bash
# Create from manifest
kubectl apply -f manifest.yaml
kubectl create -f manifest.yaml  # Only creates, fails if exists

# Edit running resource
kubectl edit pod <name> -n <namespace>

# Patch a resource
kubectl patch pod <name> -p '{"spec":{"key":"value"}}'

# Label resources
kubectl label pods <name> key=value
kubectl label nodes <name> disktype=ssd

# Delete resources
kubectl delete pod <name>
kubectl delete pods --all -n <namespace>
```

### Debugging & Logs

```bash
# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs
kubectl logs <pod-name> --previous  # Crashed container logs

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/sh
kubectl exec <pod-name> -- whoami

# Port forward for testing
kubectl port-forward pod/<pod-name> 8080:8080

# Top (resource usage)
kubectl top nodes
kubectl top pods
```

### Declarative vs Imperative

**Imperative (faster, no manifest):**
```bash
kubectl run nginx --image=nginx
kubectl expose pod nginx --port=80
kubectl set image deployment/nginx nginx=nginx:1.20
```

**Declarative (safer, version-controlled):**
```bash
kubectl apply -f deployment.yaml
```

**CKA Tip:** Mix both - use imperative for quick tasks, declarative when manifests help.

---

## 📋 Quick Reference by Domain

### Cluster Management

```bash
# Get control plane component status
kubectl get componentstatus

# Check certificate expiry
kubectl get csr

# Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets

# Uncordon node after maintenance
kubectl uncordon <node-name>

# Taint/untaint nodes
kubectl taint nodes <node-name> key=value:NoSchedule
kubectl taint nodes <node-name> key=value:NoSchedule-
```

### RBAC & Security

```bash
# Create service account
kubectl create serviceaccount <sa-name>

# Create role
kubectl create role <role-name> --verb=get,list --resource=pods

# Create rolebinding
kubectl create rolebinding <rb-name> --role=<role> --serviceaccount=<sa>

# Check permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:default

# Get secret
kubectl get secret <secret-name> -o jsonpath='{.data.password}' | base64 -d
```

### Networking

```bash
# Get services
kubectl get svc
kubectl get svc -o wide

# Expose deployment
kubectl expose deployment <name> --type=LoadBalancer --port=80

# Test DNS
kubectl run -it --rm debug --image=busybox -- nslookup <service-name>

# Port forward
kubectl port-forward svc/<service-name> 8080:80
```

### Workloads

```bash
# Scale deployment
kubectl scale deployment <name> --replicas=3

# Rollout status
kubectl rollout status deployment/<name>

# Rollout history
kubectl rollout history deployment/<name>

# Rollback
kubectl rollout undo deployment/<name>

# Update image
kubectl set image deployment/<name> <container>=<image>:tag
```

### Storage

```bash
# Get storage classes
kubectl get storageclass

# Get persistent volumes
kubectl get pv
kubectl describe pv <pv-name>

# Get persistent volume claims
kubectl get pvc
kubectl describe pvc <pvc-name>

# Troubleshoot volume binding
kubectl describe pvc <pvc-name> | grep -A5 Events
```

---

## 🎯 Exam Day Checklist

### Before Exam (Day Before)
- [ ] Download & review proctor requirements
- [ ] Test computer audio/webcam
- [ ] Clear desk, remove non-approved items
- [ ] Fully charge laptop/tablet
- [ ] Verify exam environment works 2x
- [ ] Light review only - no new topics
- [ ] Get 8 hours sleep

### Exam Morning
- [ ] Eat a good breakfast
- [ ] Use bathroom before starting
- [ ] Have water ready (allowed)
- [ ] Close all other applications
- [ ] Verify internet connection is stable
- [ ] Log in 5 minutes early

### During Exam
- [ ] Read all questions first (2-3 mins)
- [ ] Start with easy questions to build confidence
- [ ] For each question:
  - [ ] Read requirements carefully
  - [ ] Check current state first
  - [ ] Make one small change at a time
  - [ ] Verify each change works
- [ ] Use `kubectl edit` to validate syntax
- [ ] Leave explanations to the end
- [ ] Mark questionable answers for review

### Critical Exam Rules
- **DO NOT:** Use external documentation (only built-in `kubectl help`)
- **DO:** Use `man` pages - `man kubectl` is allowed!
- **DO:** Use `--help` flag extensively: `kubectl create deployment --help`
- **DO:** Use tab completion: `kubectl get <TAB>`
- **DO:** Bookmark important resources in the docs

---

## 🚨 Common Exam Traps & Solutions

### Trap 1: Wrong Namespace
**Problem:** Creating resource but it goes to wrong namespace
```bash
# Always specify namespace
kubectl create pod <name> --namespace=<correct-ns>
# OR set default
kubectl config set-context --current --namespace=<ns>
```

### Trap 2: Image Pull Errors
**Problem:** Can't pull private image or image doesn't exist
```bash
# Solution: Use simple public images for labs
# Good: nginx, busybox, alpine, ubuntu
# Bad: private/internal images in exams
```

### Trap 3: RBAC Permissions
**Problem:** Service account can't access resource
```bash
# Always verify permissions
kubectl auth can-i get pods --as=system:serviceaccount:ns:sa

# Grant permissions if needed
kubectl create rolebinding <name> \
  --role=<role> \
  --serviceaccount=<ns>:<sa>
```

### Trap 4: Node Selectors vs Affinity
**Problem:** Pod won't schedule despite labels
```bash
# Use nodeSelector for simple cases
# Use affinity for complex cases (multi-term, soft rules)
# Remember: affinity overrides nodeSelector
```

### Trap 5: Service DNS Names
**Problem:** Can't ping service
```bash
# Correct DNS names:
# - Same namespace: service-name
# - Other namespace: service-name.namespace
# - Full FQDN: service-name.namespace.svc.cluster.local

# Test connectivity
kubectl run -it --rm debug --image=busybox -- sh
# Inside pod: nslookup service-name
```

### Trap 6: StatefulSet vs Deployment
**Problem:** Using wrong resource for persistent state
```bash
# Deployment: Stateless apps, random pod names
# StatefulSet: Stateful apps, predictable names, persistent storage

# Remember: StatefulSet requires headless service!
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  clusterIP: None  # <-- Headless service!
  selector:
    app: mysql
```

---

## 💡 CKA Exam Pro Tips

### Tip 1: Learn to Skim YAML
Don't read every line—look for:
- apiVersion & kind (right resource type?)
- metadata.name (is this the resource I'm creating?)
- metadata.namespace (right namespace?)
- spec.selector (are labels matching?)
- status (check if resource is ready)

### Tip 2: Master These Commands
Practice until muscle memory:
```bash
# Daily commands (practice 50x)
kubectl get pods
kubectl get nodes
kubectl describe pod <name>
kubectl logs <pod>
kubectl exec -it <pod> -- ...
kubectl apply -f <file>
kubectl delete <resource> <name>
```

### Tip 3: Use kubectl -h Extensively
```bash
kubectl -h                    # All commands
kubectl create -h             # Create sub-commands
kubectl create pod -h         # Specific resource help
kubectl set -h                # Set operations
```

### Tip 4: Use `--dry-run` to Test
```bash
# Test if manifest is valid without applying
kubectl apply -f config.yaml --dry-run=client

# Generate manifest
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > deployment.yaml
```

### Tip 5: Copy-Paste from Docs
During exam:
- You get access to official Kubernetes docs
- **Don't memorize manifests**
- Learn the structure and required fields
- Copy-paste from docs and customize
- Know the docs navigation

### Tip 6: Verify After Every Change
```bash
# Apply, then immediately verify
kubectl apply -f file.yaml
kubectl get <resource>
kubectl describe <resource>
kubectl logs <pod>  # If it's a pod
```

### Tip 7: Use Multiple Terminals
- Terminal 1: Main work
- Terminal 2: Watch pods/events
  ```bash
  kubectl get pods -w
  kubectl get events -w
  ```

---

## 📈 Domain-Specific Focus Areas

### Cluster (25% - HIGHEST PRIORITY)
Focus on:
- [ ] kubeadm cluster initialization
- [ ] Cluster upgrade procedures
- [ ] etcd backup/restore
- [ ] Control plane component status
- [ ] HA cluster setup

**Practice:** Know kubeadm commands cold

### Services & Networking (20% - SECOND PRIORITY)
Focus on:
- [ ] Service types (ClusterIP, NodePort, LoadBalancer)
- [ ] Ingress rules and TLS
- [ ] DNS service discovery
- [ ] Network Policies
- [ ] Service troubleshooting

**Practice:** Expose different deployment types

### Troubleshooting (13% - SKILLS-BASED)
Focus on:
- [ ] Pod debugging (logs, describe, exec)
- [ ] Service connectivity
- [ ] Node status checks
- [ ] Event reading
- [ ] Common failure patterns

**Practice:** Break things intentionally, then fix them

---

## 🎓 Last Hour Before Exam

**90-60 mins before:**
- [ ] Review [STUDY_GUIDE - Command Reference](#essential-kubectl-commands)
- [ ] Quick mental walkthrough of one mock scenario
- [ ] Drink water, stretch

**60-30 mins before:**
- [ ] Rest, don't cram
- [ ] Review exam rules/setup requirements
- [ ] Do bathroom break

**30-5 mins before:**
- [ ] Light review of domain weights
- [ ] Mentally prepare for time pressure
- [ ] Take a few deep breaths

**5 mins before:**
- [ ] Close all distractions
- [ ] Start exam
- [ ] READ ALL QUESTIONS FIRST!

---

## 📊 Success Metrics

**By Day 5 of 8:**
- [ ] Can deploy all workload types without help
- [ ] Can create RBAC resources correctly
- [ ] Can troubleshoot basic pod issues
- [ ] Feel comfortable with kubectl

**By Day 7 of 8:**
- [ ] Complete mock scenario in <90 mins
- [ ] Know top 20 kubectl commands by heart
- [ ] Can identify issues from error messages
- [ ] Confident on cluster operations

**By Exam Day:**
- [ ] Completed all 3 mock scenarios
- [ ] Reviewed all domain weight percentages
- [ ] Know when to use `--help` vs documentation
- [ ] Calm and ready

---

## 🎯 Remember

**CKA is a practical exam, not theoretical.** The best preparation is:

1. **Hands-on labs** (70% of prep time)
2. **Failing and fixing** (20% of prep time)
3. **Reviewing mistakes** (10% of prep time)

**NOT:**
- Memorizing theory
- Reading without practicing
- Watching videos without labs

Focus on what **works in practice**, not what sounds right in theory.

---

**Exam Date:** April 6, 2026  
**Good Luck! 🚀 You've got this!**
