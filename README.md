# homelab

## Hardware

I am currently just running a single node cluster:

- NUC 13 with 13th generation i7
- 2TB Kingston M.2 SSD
- 2x32GB Kingston Impact

## Setup

Bootstrapping a cluster is automated via a couple of shell scripts in the `scripts` directory.
They are setup to call each other in sequence.
The scripts can be run once the nodes have booted from the Talos ISO and is waiting in maintenance mode.
See the [Talos docs](https://www.talos.dev/latest/talos-guides/install/bare-metal-platforms/iso/) for more information.

### 01-setup-cluster.sh

When the node is in maintenance mode, running this will provide the initial Talos configurations and initialize the bootstrapping of the cluster.
After the cluster is provisioned, the script will setup your `talosconfig` and `kubeconfig` to interact with the cluster.
The base Talos configuration is generated using `talosctl`, and then the patches are all applied from the `talos-patches` directory.

### 02-install-cilium.sh

After the cluster is initialized, the CNI has to be configured, I have chosen to use [Cilium](https://docs.cilium.io/en/stable/index.html).
This script will install Cilium and once complete, the node will reach a ready state.

### 03-install-argocd.sh

When the node is ready, we can install [ArgoCD](https://argoproj.github.io/) to deploy the cluster configurations.
Once this script is done, all of the workloads on the cluster will be managed by the applications defined in this repo.

The `cluster-app.yaml` is the [App of apps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) setup, which will deploy the applications in the `applications` folder.
In general, if there is a public Helm chart/Kustomize bundle/raw Kubernetes manifests available, those are used directly.
If those are not available, or if there are additional configurations required (managing `CustomResources` for example), they are defined in the `additional-deployments` directory.

### 04-get-etcd-secret.sh

[kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) is deployed on the cluster for the baseline monitoring.
Part of that includes monitoring etcd.
This script configures the Kubernetes `Secret` to allow Prometheus to scrape etcd metrics.

## Extra scripts

There are additional scripts that could be useful post-installation.

### XX-rebuild-cluster.sh

This will wipe the cluster and the nodes will reboot into maintenance mode.
This requires the node to have the Talos ISO available to boot.

### XX-test-manifests.sh

This will apply or delete some manifests to test out the software installed on the cluster.
Validation of those test manifests are manual.
