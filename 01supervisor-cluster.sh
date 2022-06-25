#!/bin/bash

#Make sure we are targeting the supervisor cluster
kubectl config use-context piper

#create the guest cluster for cnvrg
kubectl apply -f tkc.yaml

printf "Provisioning Guest Cluster..."
until [ $(kubectl get tkc cnvrg-cluster -o=jsonpath={.status.phase}) == "running" ]
do
  printf "."
  sleep 1m
done

printf "Done!\n"
printf "Run script 02 now\n"
