#! /bin/sh

set -euo

kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install cluster argo/argo-cd --namespace argocd --set fullnameOverride=argocd --set configs.cm."kustomize\.buildOptions"=--enable-helm

echo "Click enter when argocd is ready for the cluster-app"
read -p ""

kubectl apply -f cluster-app.yaml

# TODO: Fix ordering of all the apps
