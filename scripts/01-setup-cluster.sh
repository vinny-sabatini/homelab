#! /bin/sh
# Requires NODE_IP to be passed in
# Example: 01-setup-cluster.sh 1.2.3.4

set -euo

export CLUSTER_NAME=talos-cluster
export NODE_IP=$1

# Generate base configuration files
talosctl gen config ${CLUSTER_NAME} https://${NODE_IP}:6443 \
    --force \
    --install-disk /dev/nvme0n1 \
    --config-patch @talos-patches/control-plane-scheduling.yaml \
    --config-patch @talos-patches/disable-cni-and-kube-proxy.yaml \
    --config-patch @talos-patches/kube-services-bind.yaml \
    --config-patch @talos-patches/local-path-storage.yaml \
    --config-patch @talos-patches/rotate-server-certificates.yaml \
    --config-patch @talos-patches/volume-configs.yaml

mkdir -p $HOME/.talos
yq '.contexts.talos-cluster.endpoints += [strenv(NODE_IP)]' -i ./talosconfig
yq '.contexts.talos-cluster.nodes += [strenv(NODE_IP)]' -i ./talosconfig
cp talosconfig $HOME/.talos/config

echo "Click enter when serial console is looking for configuration file"
read -p ""

talosctl apply-config --insecure --nodes ${NODE_IP} --file controlplane.yaml

echo "Click enter when serial console is waiting for bootstrap"
read -p ""

# Once the configs finish applying, bootstrap the cluster
talosctl bootstrap

echo "Click enter when ready to bootstrap CNI (failing to get pods)"
read -p ""

# Add cluster to kubeconfig
talosctl kubeconfig --force

./scripts/02-install-cilium.sh ${NODE_IP}
