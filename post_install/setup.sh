#!/bin/bash

{% set HELM_VERSION = salt['pillar.get']('kubernetes:global:helm-version') -%}

# kubectl apply -f rbac-calico.yaml
kubectl apply -f calico.yaml
# sleep 10
#kubectl apply -f kube-dns.yaml
# kubectl apply -f coredns.yaml
kubectl apply -f kubernetes-dashboard.yaml

kubectl apply -f heapster-rbac.yaml
# kubectl apply -f influxdb.yaml
kubectl apply -f grafana.yaml
kubectl apply -f heapster.yaml

## Install Helm
# wget https://kubernetes-helm.storage.googleapis.com/helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
# tar -zxvf helm-{{ HELM_VERSION }}-linux-amd64.tar.gz
# mv linux-amd64/helm /usr/local/bin/helm
# rm -r linux-amd64/ && rm -r helm-{{ HELM_VERSION }}-linux-amd64.tar.gz

# kubectl apply serviceaccount tiller --namespace kube-system

# kubectl apply -f rbac-tiller.yaml
# helm init --service-account tiller

sleep 2
echo ""
echo "Kubernetes is now fully configured "
echo ""
kubectl get pod,deploy,svc --all-namespaces
echo ""
kubectl get nodes
echo ""
