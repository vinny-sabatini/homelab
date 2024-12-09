# homelab

## Hardware

- NUC 13 with 13th generation i7
- 2TB Kingston M.2 SSD
- 2x32GB Kingston Impact

## Setup

### Install Talos via ISO

- https://www.talos.dev/v1.9/talos-guides/install/bare-metal-platforms/iso/

When the node is booted and has an IP, use `scripts/01-setup-cluster.sh` script to bootstrap the cluster

### Install Cilium

When the cluster is healthy and you have the kubeconfig, run `scripts/02-install-cilium.sh` to install Cilium.
This will also bring the control plane into a ready state (you may need to approve the CSR with `kubectl certificate approve`).

### Install ArgoCD

When the cluster is up and running, run `scripts/03-install-argocd.sh` to install ArgoCD.
At this point, the cluster is ready, and all Kubernetes manifests are managed via ArgoCD.
