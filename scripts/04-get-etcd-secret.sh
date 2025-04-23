#! /bin/sh

set -euo

# Create etcd certificate Kubernetes secret for etcd Prometheus monitoring
# Ref https://github.com/siderolabs/talos/discussions/7214#discussioncomment-11709688

etcd_ca=$(talosctl get etcdrootsecret  -o yaml | yq .spec.etcdCA.crt)
etcd_crt=$(talosctl get etcdsecret -o yaml | yq .spec.etcd.crt)
etcd_key=$(talosctl get etcdsecret -o yaml | yq .spec.etcd.key)

kubectl create ns monitoring

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: etcd-client-cert
  namespace: monitoring
type: Opaque
data:
  etcd-ca.crt:
    ${etcd_ca}
  etcd-client.crt:
    ${etcd_crt}
  etcd-client-key.key:
    ${etcd_key}
EOF
