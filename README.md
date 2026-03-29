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
