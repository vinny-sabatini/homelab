#! /bin/sh

set -euo

kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm install cluster argo/argo-cd --namespace argocd --set fullnameOverride=argocd
kubectl apply -f cluster-app.yaml
