#! /bin/sh

set -euo

bitwarden_token=$(echo -n $1 | base64 -w 0)

kubectl create namespace external-secrets

cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: bitwarden-access-token
  namespace: external-secrets
data:
  token: ${bitwarden_token}
EOF
