# CKA Learning Path - Complete Index

This is your **navigation hub**. Follow the recommended learning sequence below or jump to specific topics.

## 🎯 Recommended Learning Path (8 Days)

### Day 1: Foundation & Cluster Understanding
**Focus:** Cluster architecture (25% of exam - highest weight!)
- [ ] Read: [Cluster Basics - Concepts](./cluster-basics/README.md)
- [ ] Lab: [kubeadm and Cluster Architecture](./cluster-basics/01-cluster-setup.md)
- [ ] Lab: [Cluster Upgrade Procedures](./cluster-basics/02-cluster-upgrade.md)
- [ ] Quick Review: [STUDY_GUIDE - Cluster Commands](./STUDY_GUIDE.md#cluster-commands)

### Day 2: Workloads & Deployments  
**Focus:** Managing application workloads (15% of exam)
- [ ] Read: [Workloads Overview](./workloads/README.md)
- [ ] Lab: [Pods](./workloads/01-pods.md)
- [ ] Lab: [Deployments](./workloads/02-deployments.md)
- [ ] Lab: [StatefulSets](./workloads/03-statefulsets.md)
- [ ] Lab: [DaemonSets & Jobs](./workloads/04-daemonsets-jobs.md)

### Day 3: Networking Foundations
**Focus:** Services and networking (20% of exam - second highest!)
- [ ] Read: [Networking Overview](./networking/README.md)
- [ ] Lab: [Services Basics](./networking/01-services.md)
- [ ] Lab: [Ingress Resources](./networking/02-ingress.md)
- [ ] Quick Lab: [DNS in Kubernetes](./networking/03-dns.md)

### Day 4: Scheduling & Resource Management
**Focus:** Workload placement and constraints (5% of exam)
- [ ] Lab: [Taints & Tolerations](./scheduling/01-taints-tolerations.md)
- [ ] Lab: [Node Affinity](./scheduling/02-node-affinity.md)
- [ ] Lab: [Pod Affinity & Anti-Affinity](./scheduling/03-pod-affinity.md)
- [ ] Lab: [Resource Requests & Limits](./scheduling/04-resource-limits.md)

### Day 5: Storage & Persistence
**Focus:** Storage management (10% of exam)
- [ ] Read: [Storage Overview](./storage/README.md)
- [ ] Lab: [PersistentVolumes & Claims](./storage/01-pv-pvc.md)
- [ ] Lab: [Storage Classes](./storage/02-storageclass.md)
- [ ] Lab: [StatefulSet Storage](./storage/03-statefulset-storage.md)

### Day 6: Security & Access Control
**Focus:** RBAC and security (12% of exam)
- [ ] Read: [Security Overview](./security/README.md)
- [ ] Lab: [ServiceAccounts](./security/01-serviceaccounts.md)
- [ ] Lab: [Roles & RoleBindings](./security/02-rbac.md)
- [ ] Lab: [Network Policies](./security/03-networkpolicies.md)
- [ ] Lab: [Pod Security](./security/04-pod-security.md)

### Day 7: Troubleshooting & Advanced Debugging
**Focus:** Problem-solving skills (13% of exam - crucial!)
- [ ] Read: [Troubleshooting Overview](./troubleshooting/README.md)
- [ ] Lab: [Pod Debugging](./troubleshooting/01-debug-pods.md)
- [ ] Lab: [Service Troubleshooting](./troubleshooting/02-debug-services.md)
- [ ] Lab: [Node & Cluster Issues](./troubleshooting/03-debug-cluster.md)
- [ ] Scenario: [Mock Exam Scenario #1](./mock-scenarios/scenario-1.md)

### Day 8: Review & Practice Exams
**Focus:** Consolidation and timed practice
- [ ] Review: [STUDY_GUIDE Command Reference](./STUDY_GUIDE.md)
- [ ] Scenario: [Mock Exam Scenario #2](./mock-scenarios/scenario-2.md) (90 mins, timed)
- [ ] Scenario: [Mock Exam Scenario #3](./mock-scenarios/scenario-3.md) (90 mins, timed)
- [ ] Final prep checklist: [STUDY_GUIDE - Exam Day](./STUDY_GUIDE.md#exam-day-checklist)

---

## 📂 By Exam Domain

### Cluster Architecture, Installation & Maintenance (25% weight - **PRIORITY**)
- [Cluster Basics Module](./cluster-basics/)
  - Cluster setup with kubeadm
  - Cluster upgrade and rollback
  - Backup and restore etcd
  - Binary upgrades
  - High Availability setup
  - Cloud provider integrations

### Workloads & APIs (15% weight)
- [Workloads Module](./workloads/)
  - Pod creation and configuration
  - Deployments and rolling updates
  - StatefulSets for stateful apps
  - DaemonSets and Jobs
  - Network policies for workloads
  - Helm basics

### Scheduling & Eviction (5% weight)
- [Scheduling Module](./scheduling/)
  - Taints and tolerations
  - Node affinity and pod affinity
  - Resource requests and limits
  - Pod disruption budgets
  - Static pod configuration

### Services & Networking (20% weight - **PRIORITY**)
- [Networking Module](./networking/)
  - Service types and exposure
  - Ingress controllers
  - Network policies and security
  - DNS and service discovery
  - CoreDNS configuration
  - Troubleshooting connectivity

### Storage (10% weight)
- [Storage Module](./storage/)
  - Volumes and PersistentVolumes
  - PersistentVolumeClaims
  - StorageClasses
  - Stateful applications with storage
  - Volume snapshots
  - Data persistence

### Security (12% weight)
- [Security Module](./security/)
  - Authentication and authorization (RBAC)
  - ServiceAccounts and tokens
  - Roles and ClusterRoles
  - Pod security standards
  - Network policies
  - Secrets and ConfigMaps
  - Security contexts

### Troubleshooting (13% weight - **CRITICAL**)
- [Troubleshooting Module](./troubleshooting/)
  - Application failure diagnosis
  - Control plane troubleshooting
  - Worker node issues
  - Networking issues
  - Storage issues
  - Performance debugging

---

## 🎓 Lab Types

### Quick Labs (⏱️ 10-15 minutes)
Perfect for learning a single concept in isolation.
- **Best for:** Learning new topics, building confidence
- **Example:** [Basic Pod Creation](./workloads/01-pods.md#quick-lab-1-create-your-first-pod)

### Comprehensive Labs (⏱️ 30-60 minutes)
Deeper practice combining multiple concepts.
- **Best for:** Integration practice, real-world scenarios
- **Example:** [Multi-tier Application Deployment](./workloads/02-deployments.md#comprehensive-lab-deploy-a-multi-tier-app)

### Mock Exam Scenarios (⏱️ 90 minutes)
Full exam-like conditions with time pressure.
- **Best for:** Final review, pacing practice, identifying weak areas
- **All scenarios:** [Mock Scenarios Directory](./mock-scenarios/)

---

## 🔍 Quick Reference

### By Difficulty Level

**Beginner-Friendly (Start Here)**
1. [Workloads - Pods](./workloads/01-pods.md)
2. [Cluster Basics - Concepts](./cluster-basics/README.md)
3. [Networking - Services](./networking/01-services.md)

**Intermediate (Mid-Preparation)**
1. [Scheduling - All labs](./scheduling/)
2. [Workloads - StatefulSets](./workloads/03-statefulsets.md)
3. [Storage - PV/PVC](./storage/01-pv-pvc.md)

**Advanced (Exam Ready)**
1. [Security - RBAC deep dive](./security/02-rbac.md)
2. [Troubleshooting - All scenarios](./troubleshooting/)
3. [Cluster - HA setup](./cluster-basics/05-high-availability.md)

### By Time Available

**15 minutes:** Any "Quick Lab" marked with ⏱️
**30 minutes:** Any "Comprehensive Lab"  
**90 minutes:** Any "Mock Exam Scenario"

---

## 📊 Progress Tracking

Use [PROGRESS_TRACKER.md](./PROGRESS_TRACKER.md) to:
- Check off completed labs
- Note difficult topics
- Track time spent per domain
- Log weak areas for review

---

## 💡 Tips for Success

1. **Don't Skip the Basics** - Cluster architecture (25%) is heavily weighted
2. **Practice Time Management** - Mock scenarios should simulate exam pressure
3. **Learn kubectl Well** - ~40% of exam is practical typing, not MCQ
4. **Review After Failures** - Failed labs are learning opportunities
5. **Test on Your AKS Cluster** - Use [SETUP_GUIDE.md](./SETUP_GUIDE.md) to prepare
6. **Command Mastery** - Use [STUDY_GUIDE - Commands](./STUDY_GUIDE.md#essential-kubectl-commands)

---

## 📌 Last-Minute Resources

**2 Days Before Exam:**
- Review [STUDY_GUIDE.md](./STUDY_GUIDE.md)
- Do mock scenarios #2 and #3 back-to-back
- Check [Command Reference](./STUDY_GUIDE.md#essential-kubectl-commands)

**Day Before Exam:**
- Light review only - no new topics
- Read [Exam Day Checklist](./STUDY_GUIDE.md#exam-day-checklist)
- Get good sleep!

**Exam Day:**
- Review [Time Management Tips](./STUDY_GUIDE.md#time-management)
- Stay calm - you've got this! 💪

---

**Exam Date:** April 6, 2026  
**Days to Exam:** 8 days  
**Good luck! 🚀**
