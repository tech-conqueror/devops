#!/bin/bash

kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner # indicates that this StorageClass does not support automatic provisioning
volumeBindingMode: WaitForFirstConsumer
EOF

kubectl delete namespace artifactory-oss
kubectl delete pv --all

kubectl create namespace artifactory-oss

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-artifactory-oss-postgresql-0
spec:
  storageClassName: local-storage
  volumeMode: Filesystem
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  local:
    path: /var/opt/jfrog/artifactory-database
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - machine-02
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-artifactory-oss-postgresql-0
  namespace: artifactory-oss
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  volumeName: data-artifactory-oss-postgresql-0
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: artifactory-volume-artifactory-oss-0
spec:
  storageClassName: local-storage
  volumeMode: Filesystem
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  local:
    path: /var/opt/jfrog/artifactory
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - machine-02
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: artifactory-volume-artifactory-oss-0
  namespace: artifactory-oss
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  volumeName: artifactory-volume-artifactory-oss-0
EOF

kubectl create secret generic masterkey-secret -n artifactory-oss --from-literal=master-key=8b7ea73617bc1512dfe22102d051b9c495b53022340f27739978788be2242f13
kubectl create secret generic joinkey-secret -n artifactory-oss --from-literal=join-key=46e2265fb2cda9c365d9e947d4e3a569f96a1b4e245f0f28f6fe86c49cc01946

kubectl get pvc -n artifactory-oss

helm upgrade --install artifactory-oss -f artifactory-xsmall.yaml \
  --set artifactory.postgresql.postgresqlPassword=pwd \
  --set artifactory.artifactory.masterKeySecretName=masterkey-secret \
  --set artifactory.artifactory.joinKeySecretName=joinkey-secret \
  --set artifactory.nginx.enabled=false \
  --set artifactory.ingress.enabled=true \
  --set artifactory.ingress.hosts[0]="artifactory.techconqueror.com" \
  --set artifactory.artifactory.service.type=NodePort \
  --set artifactory.postgresql.volumePermissions.enabled=true \
  artifactory-oss/artifactory-oss --namespace artifactory-oss --create-namespace \
  --version 107.98.13
