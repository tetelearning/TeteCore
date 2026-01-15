#!/bin/bash
export BUILD_NUMBER=333

envsubst <./do-prod.yml >./do-prod.yml.out
mv ./do-prod.yml.out ./do-prod-filled.yml
kubectl --kubeconfig="tete-prod-k8s-1-18-8-do-1-sfo2-1602065310385-kubeconfig.yaml" apply -f ./do-prod-filled.yml