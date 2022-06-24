# Dell Demo Center Prep

#### Install Notes
* Create new DNS Zone cnvrg.demo.local
* Create wildcard A record and point to 192.168.140.250
* This will deploy to http://app.cnvrg.demo.local
* https://github.com/nctiggy/democenter-cnvrg
* Run scripts 01 and 02

## Tanzu Supervisor Cluster Prep
### VirtualMachineClass
Must have at least 6 cpu for worker nodes
```
apiVersion: vmoperator.vmware.com/v1alpha1
kind: VirtualMachineClass
metadata:
  name: cnvrg-reg
spec:
  hardware:
    cpus: 6
    devices: {}
    memory: 16Gi
  policies:
    resources:
      limits:
        cpu: "0"
        memory: "0"
      requests:
        cpu: "0"
        memory: "0"
```
### TanzuKubernetesCluster
The cluster must be k8s 1.20 or 1.21
- MetalLb requires 1.20 or higher
- cnvrg requires 1.21 or lower

```
apiVersion: run.tanzu.vmware.com/v1alpha2
kind: TanzuKubernetesCluster
metadata:
  annotations:
  labels:
    run.tanzu.vmware.com/tkr: v1.20.12---vmware.1-tkg.1.b9a42f3
  name: cnvrg-cluster
  namespace: piper
spec:
  distribution:
    fullVersion: 1.20.12+vmware.1-tkg.1.b9a42f3
    version: v1.20.12
  settings:
    network:
      cni:
        name: calico
      pods:
        cidrBlocks:
        - 192.0.2.0/24
      serviceDomain: cluster.local
      services:
        cidrBlocks:
        - 198.51.100.0/24
    storage:
      classes:
      - vsan-default-storage-policy
      defaultClass: vsan-default-storage-policy
  topology:
    controlPlane:
      replicas: 1
      storageClass: vsan-default-storage-policy
      tkr:
        reference:
          name: v1.20.12---vmware.1-tkg.1.b9a42f3
      vmClass: best-effort-large
    nodePools:
    - name: workers
      replicas: 5
      storageClass: vsan-default-storage-policy
      tkr:
        reference:
          name: v1.20.12---vmware.1-tkg.1.b9a42f3
      vmClass: cnvrg-reg
      volumes:
      - capacity:
          storage: 100Gi
        mountPath: /var/lib/containerd
        name: ephemeral
```
## Tanzu Guest Cluster Prep
### StorageClass
This addresses a bug in the vsan CSI driver that ignores fsGroup if the fstype is not set. This class still links to the vsan-default-storage-policy in vSphere
```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cnvrg
parameters:
  svStorageClass: vsan-default-storage-policy
  csi.storage.k8s.io/fstype: "ext4"
provisioner: csi.vsphere.vmware.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
```
### ClusterRoleBinding
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: default-tkg-admin-privileged-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: psp:vmware-system-privileged
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:authenticated
```
### MetalLB Deployment
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
```
### MetalLB ConfigMap
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.140.250-192.168.140.252
```
### cvnrg helm install values.yaml
```
registry:
  user: cnvrghelm
  password: abbb7835-fef8-42af-be0f-ef6750bde5a0
controlPlane:
  image: cnvrg/app:v3.12.17
  baseConfig:
    featureFlags:
      CNVRG_MOUNT_HOST_FOLDERS: false
  mpi:
    registry:
      user: cnvrghelm
      password: abbb7835-fef8-42af-be0f-ef6750bde5a0
clusterDomain: cnvrg.demo.local
dbs:
  redis:
    storageClass: cnvrg
  minio:
    storageClass: cnvrg
  pg:
    storageClass: cnvrg
  es:
    storageClass: cnvrg
logging:
  elastalert:
    storageClass: cnvrg
monitoring:
  prometheus:
    storageClass: cnvrg
```
### cnvrg helm deployment commands
```
helm repo add cnvrgv3 https://charts.v3.cnvrg.io
helm repo update
helm upgrade --install cnvrg cnvrgv3/cnvrg -n cnvrg --create-namespace --values values.yaml
```
