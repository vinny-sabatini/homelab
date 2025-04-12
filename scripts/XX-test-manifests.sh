#! /bin/sh

# Provide apply or delete for the tests

set -euo

kubectl $1 -f ./scripts/tests/kubevirt-vm.yaml
kubectl $1 -f ./scripts/tests/storageclass-local-path.yaml
