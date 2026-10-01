#! /bin/sh
# Example: 01-setup-cluster.sh

set -euo

export CLUSTER_NAME=talos-cluster
export ENDPOINT=kube.vinnysabatini.me
# 192.168.3.3 is a NUC
# 192.168.3.4 and 192.168.3.5 are minisforums
# They have different network interfaces
export CONTROL_PLANE_IP=("192.168.3.3" "192.168.3.4" "192.168.3.5")

talosctl gen secrets --force -o secrets.yaml

# Generate base configuration files
talosctl gen config --with-secrets secrets.yaml ${CLUSTER_NAME} https://${ENDPOINT}:6443 --force \
    --install-disk /dev/nvme0n1 \
    --additional-sans=${ENDPOINT} \
    --output-types controlplane,talosconfig \
    --config-patch-control-plane talos-patches/control-plane-scheduling.yaml \
    --config-patch-control-plane talos-patches/disable-cni-and-kube-proxy.yaml \
    --config-patch-control-plane talos-patches/etcd-metrics-patch.yaml \
    --config-patch-control-plane talos-patches/kube-services-bind.yaml \
    --config-patch-control-plane talos-patches/logging-configuration.yaml \
    --config-patch-control-plane talos-patches/rotate-server-certificates.yaml \
    --config-patch-control-plane talos-patches/tuppr-kube-api-access.yaml \
    --config-patch-control-plane talos-patches/user-namespaces.yaml \
    --config-patch-control-plane talos-patches/volume-configs.yaml

talosctl machineconfig patch controlplane.yaml --patch talos-patches/nuc-patch.yaml --output controlplane-nuc.yaml
talosctl machineconfig patch controlplane.yaml --patch talos-patches/minisforum-patch.yaml --output controlplane-minisforum.yaml

mkdir -p $HOME/.talos
cp talosconfig $HOME/.talos/config
talosctl config endpoint "${CONTROL_PLANE_IP[@]}"

echo "Click enter when serial console is looking for configuration file"
read -p ""

talosctl apply-config --insecure --nodes 192.168.3.3 --file controlplane-nuc.yaml
talosctl apply-config --insecure --nodes 192.168.3.4 --file controlplane-minisforum.yaml
talosctl apply-config --insecure --nodes 192.168.3.5 --file controlplane-minisforum.yaml

echo "Click enter when serial console is waiting for bootstrap"
read -p ""

# Once the configs finish applying, bootstrap the cluster
talosctl bootstrap --nodes=192.168.3.3

echo "Click enter when ready to bootstrap CNI (failing to get pods)"
read -p ""

# Add cluster to kubeconfig
talosctl kubeconfig --force --nodes=192.168.3.3

./scripts/02-install-cilium.sh
