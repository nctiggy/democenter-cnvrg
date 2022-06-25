#!/bin/bash

POWDER_BLUE=$(tput setaf 153)
MAGENTA=$(tput setaf 5)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
CHECK="\xE2\x9C\x94"

printf "${POWDER_BLUE}Logging into k8s via vSphere${NORMAL}..."
export KUBECTL_VSPHERE_PASSWORD=Password123!
kubectl vsphere login --server=https://192.168.140.210 --vsphere-username administrator@vsphere.local --tanzu-kubernetes-cluster-namespace piper --insecure-skip-tls-verify > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

#Make sure we are targeting the supervisor cluster
printf "${POWDER_BLUE}Switch context to piper${NORMAL}..."
kubectl config use-context piper > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

#create the guest cluster for cnvrg
printf "${POWDER_BLUE}Initializing Guest Cluster${NORMAL}"
kubectl apply -f tkc.yaml > /dev/null 2>&1

until [[ -n $(kubectl get tkc cnvrg-cluster -o=jsonpath={.status.phase}) ]]
do
  printf "."
  sleep 5s
done
printf "${GREEN}${CHECK}${NORMAL}\n\n"
printf "${POWDER_BLUE}Creating Nodes${NORMAL}"
until [[ $(kubectl get tkc cnvrg-cluster -o=jsonpath={.status.phase}) == "running" ]]
do
  printf "."
  sleep 30s
done

printf "${GREEN}${CHECK}${NORMAL}\n\n"

printf "${GREEN}k8s Cluster Ready!${NORMAL}\n"
printf "${MAGENTA}Run script 02 now${NORMAL}\n"
