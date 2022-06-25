#!/bin/bash

#Make sure we are targeting the supervisor cluster
kubectl config use-context piper
#Create the vmclass for cnvrg
kubectl apply -f vmclass.yaml
#create the guest cluster for cnvrg
kubectl apply -f tkc.yaml

printf "Provisioning Guest Cluster...
until $(kubectl get tkc tkc-cluster-01 -o=jsonpath={.status.phase}) == "running"
do
  printf "."
  sleep 1m
done

printf "Done!\n"
