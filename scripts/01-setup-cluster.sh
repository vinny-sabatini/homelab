#! /bin/sh
# Requires NODE_IP to be passed in
# Example: 01-setup-cluster.sh 1.2.3.4

set -euo

CLUSTER_NAME=talos-cluster
NODE_IP=$1

# Generate base configuration files
talosctl gen config ${CLUSTER_NAME} https://${NODE_IP}:6443 \
    --install-disk /dev/nvme0n1 \
    --config-patch @talos-patches/disable-cni-and-kube-proxy.yaml \
    --config-patch @talos-patches/rotate-server-certificates.yaml \
    --config-patch @talos-patches/control-plane-scheduling.yaml \
    --config-patch @talos-patches/kube-services-bind.yaml \
    --config-patch @talos-patches/local-path-storage.yaml


talosctl apply-config --insecure --nodes ${NODE_IP} --file controlplane.yaml

# Once the configs finish applying, bootstrap the cluster
talosctl bootstrap --nodes ${NODE_IP} --endpoints ${NODE_IP} --talosconfig=./talosconfig

# Review cluster health
talosctl --nodes ${NODE_IP} --endpoints ${NODE_IP} --talosconfig=./talosconfig health
talosctl --nodes ${NODE_IP} --endpoints ${NODE_IP} --talosconfig=./talosconfig dashboard

# Add cluster to kubeconfig
talosctl --nodes ${NODE_IP} --endpoints ${NODE_IP} --talosconfig=./talosconfig kubeconfig
