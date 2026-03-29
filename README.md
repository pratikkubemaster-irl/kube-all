# CKA Exam Preparation - Kubernetes Learning Project

A comprehensive hands-on learning project for preparing for the **Certified Kubernetes Administrator (CKA)** exam. This repository contains practical labs, YAML manifests, study guides, and mock exam scenarios covering all major CKA exam domains.

**Exam Date:** April 6, 2026

## 📚 What's Inside

This project is organized by **CKA exam domains**. Each module includes:
- **Study Materials** - Concepts, key points, and exam tips
- **Practical Labs** - Step-by-step deployments you can run on your AKS cluster
- **YAML Templates** - Ready-to-use manifest files
- **Troubleshooting** - Common issues and solutions

## 🎯 CKA Exam Domains Covered

| Domain | Weight | Module | Status |
|--------|--------|--------|--------|
| Cluster Architecture & Installation | 25% | [Cluster Basics](./cluster-basics/) | ✅ |
| Workloads & APIs | 15% | [Workloads](./workloads/) | ✅ |
| Scheduling & Eviction | 5% | [Scheduling](./scheduling/) | ✅ |
| Services & Networking | 20% | [Networking](./networking/) | ✅ |
| Storage | 10% | [Storage](./storage/) | ✅ |
| Security | 12% | [Security & RBAC](./security/) | ✅ |
| Troubleshooting | 13% | [Troubleshooting](./troubleshooting/) | ✅ |

## 🚀 Quick Start

### Prerequisites
- Access to an AKS cluster (already connected in VS Code)
- `kubectl` installed and configured
- Basic Kubernetes knowledge (pods, services, deployments)

### Setup
1. Clone this repository
2. Follow [SETUP_GUIDE.md](./SETUP_GUIDE.md) to prepare your cluster
3. Start with the [Project Index](./index.md) for guided learning path

### Running Your First Lab
```bash
# Navigate to any module
cd cluster-basics/

# Read the lab instructions
cat 01-kubeadm-setup.md

# Deploy the manifests
kubectl apply -f manifests/
```

## 📖 Documentation Structure

- **[index.md](./index.md)** - Navigation hub and learning path
- **[SETUP_GUIDE.md](./SETUP_GUIDE.md)** - Initial cluster setup on AKS
- **[STUDY_GUIDE.md](./STUDY_GUIDE.md)** - Exam tips, command reference, time management
- **[PROGRESS_TRACKER.md](./PROGRESS_TRACKER.md)** - Track your learning progress

## 📂 Module Structure

Each module contains:
```
module-name/
├── README.md                 # Module overview
├── 01-concept-1.md          # Topic 1 with labs
├── 02-concept-2.md          # Topic 2 with labs
├── manifests/               # YAML template files
│   ├── example-1.yaml
│   └── example-2.yaml
└── troubleshooting/         # Common issues for this domain
    └── issues.md
```

## 🔬 Lab Categories

### Quick Labs (10-15 mins)
- Single concept practice
- Isolated exercises
- Perfect for learning a new topic

### Comprehensive Labs (30-60 mins)
- Multi-step scenarios
- Integration with other concepts
- Closer to real-world tasks

### Mock Exam Scenarios (90 mins)
- Time-pressured exercises
- Multiple concepts combined
- Realistic exam conditions
- See [mock-scenarios/](./mock-scenarios/)

## ⏱️ Study Timeline (8 Days to Exam)

### Week 1 (Days 1-4)
- Day 1: Cluster Basics concepts + setup labs
- Day 2: Workloads labs (Pods, Deployments, StatefulSets)
- Day 3: Scheduling & Networking (quick labs only)
- Day 4: Storage & Security (overview only)

### Week 2 (Days 5-8)
- Day 5: Complete Scheduling + Networking labs
- Day 6: Storage & Security deep dive
- Day 7: Troubleshooting labs + mock scenario #1
- Day 8: Review, mock scenarios #2-3, command drills

## 🎓 How to Use This Repository

1. **Learn by doing** - Don't just read, deploy the manifests on your cluster
2. **Test locally first** - Each lab includes verification steps
3. **Track progress** - Use [PROGRESS_TRACKER.md](./PROGRESS_TRACKER.md)
4. **Time yourself** - Mock scenarios should be done under pressure
5. **Re-read on failure** - If a lab fails, re-read the concept before trying again

## 🛠️ AKS-Specific Notes

- All labs are tested on AKS and include AKS-specific tips where needed
- Some labs use Azure-specific resources (e.g., Azure Disk storage classes)
- See [SETUP_GUIDE.md](./SETUP_GUIDE.md) for AKS cluster configuration

## 📋 Exam Day Tips

- See **[STUDY_GUIDE.md](./STUDY_GUIDE.md)** for:
  - Time management strategies
  - Essential kubectl commands
  - Common exam traps and gotchas
  - Last-minute review checklist

## 🤝 Contributing & Updating

- Feel free to add your own notes in the PROGRESS_TRACKER
- Update manifests if they fail on your cluster
- Commit frequently to track your learning journey

## 📝 License

Educational project for CKA exam preparation. Use freely for learning purposes.

---

**Last Updated:** March 29, 2026  
**Target Exam:** April 6, 2026  
**Days Remaining:** 8 days

**Good luck with your CKA exam! 💪**
