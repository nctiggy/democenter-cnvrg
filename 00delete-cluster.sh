#!/bin/bash

POWDER_BLUE=$(tput setaf 153)
MAGENTA=$(tput setaf 5)
NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2)
CHECK="\xE2\x9C\x94"

printf "${POWDER_BLUE}Switch context to piper${NORMAL}..."
kubectl config use-context piper > /dev/null 2>&1
printf "${GREEN}${CHECK}${NORMAL}\n"

printf "${POWDER_BLUE}Deleting cluster${NORMAL}"
kubectl delete tkc cnvrg-cluster --wait=false > /dev/null 2>&1

until [ $? == 1 ]
do
  printf "."
  sleep 30s
  kubectl get tkc cnvrg-cluster > /dev/null 2>&1
done

printf "${GREEN}${CHECK}${NORMAL}\n\n"
