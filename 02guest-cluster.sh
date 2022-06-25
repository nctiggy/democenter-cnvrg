#!/bin/bash

POWDER_BLUE=$(tput setaf 153)
MAGENTA=$(tput setaf 5)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
CHECK="\xE2\x9C\x94"

#Make sure we are targeting the supervisor cluster
printf "${POWDER_BLUE}Logging into k8s via vSphere${NORMAL}..."
export KUBECTL_VSPHERE_PASSWORD=Password123!
kubectl vsphere login --server=https://192.168.140.210 --vsphere-username administrator@vsphere.local --tanzu-kubernetes-cluster-namespace piper --tanzu-kubernetes-cluster-name cnvrg-cluster --insecure-skip-tls-verify > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Switch context to cnvrg-cluster${NORMAL}..."
kubectl config use-context cnvrg-cluster > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Apply StorageClass${NORMAL}..."
kubectl apply -f storage-class.yaml > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Apply ClusterRoleBinding${NORMAL}..."
kubectl apply -f cluster-role-binding.yaml > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Create metallb namespace${NORMAL}..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Deploy metallb${NORMAL}..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Apply metallb ConfigMap${NORMAL}..."
kubectl apply -f metallb-config-map.yaml > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Adding cnvrg helm repo${NORMAL}..."
helm repo add cnvrgv3 https://charts.v3.cnvrg.io > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Update helm repos${NORMAL}..."
helm repo update > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Intalling cnvrg${NORMAL}..."
helm upgrade --install cnvrg cnvrgv3/cnvrg -n cnvrg --create-namespace --wait --timeout 10m0s --values values.yaml > /dev/null 2>&1 &
pid=$!
while [ "$(ps a | awk '{print $1}' | grep $pid)" ]
do
  printf "."
  sleep 20s
done
printf "${GREEN}${CHECK}${NORMAL}\n\n"

printf "${MAGENTA}cnvrg has deployed! http://app.cnvrg.demo.local${NORMAL}"
