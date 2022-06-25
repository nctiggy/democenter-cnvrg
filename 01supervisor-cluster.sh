#!/bin/bash

POWDER_BLUE=$(tput setaf 153)
MAGENTA=$(tput setaf 5)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)

#Make sure we are targeting the supervisor cluster
kubectl config use-context piper

#create the guest cluster for cnvrg
kubectl apply -f tkc.yaml

printf "${POWDER_BLUE}Provisioning Guest Cluster..."
until [[ -n $(kubectl get tkc cnvrg-cluster -o=jsonpath={.status.phase}) ]]
do
  printf "${NORMAL}."
  sleep 1m
done
printf "${GREEN}Init Complete!\n"
printf "${POWDER_BLUE}Creating Nodes"
until [[ $(kubectl get tkc cnvrg-cluster -o=jsonpath={.status.phase}) == "running" ]]
do
  printf "${NORMAL}."
  sleep 1m
done

printf "${GREEN}Cluster Complete!\n\n"
printf "${MAGENTA}Run script 02 now\n"
