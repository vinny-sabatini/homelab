#! /bin/sh

set -euo

kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install cluster argo/argo-cd --namespace argocd --set fullnameOverride=argocd

echo "Click enter when argocd is ready for the cluster-app"
read -p ""

kubectl apply -f cluster-app.yaml

./scripts/04-get-etcd-secret.sh
