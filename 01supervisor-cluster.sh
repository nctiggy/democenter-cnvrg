#Make sure we are targeting the supervisor cluster
kubectl config use-context piper
#Create the vmclass for cnvrg
kubectl apply -f vmclass.yaml
#create the guest cluster for cnvrg
kubectl apply -f tkc.yaml
