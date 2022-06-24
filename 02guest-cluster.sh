#!/bin/bash
kubectl config use-context cnvrg-cluster

kubectl apply -f storage-class.yaml

kubectl apply -f cluster-role-binding.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

kubectl apply -f metallb-config-map.yaml

helm repo add cnvrgv3 https://charts.v3.cnvrg.io

helm repo update

helm upgrade --install cnvrg cnvrgv3/cnvrg -n cnvrg --create-namespace --values values.yaml
