#!/bin/bash

#RBDTARGETS=("sonarr-config" "nzbhydra2-config" "radarr-config" "bitwarden-bitwarden-k8s" "tautulli-config" "unifi")
RBDTARGETS=("nzbhydra2-config")
NFSTARGETS=("nzbget-config")
FOLDER="2020.02.08"
TOOLS=`kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}'`

echo "Mounting NFS Storage Location where Backups are"
kubectl -n rook-ceph exec -it "$TOOLS" -- sh -c "mkdir -p /mnt/nfs && mount -t nfs 10.20.50.100:/ /mnt/nfs || /bin/true"

for i in "${RBDTARGETS[@]}"
do
    echo "Processing $i..."
    PV=csi-vol-`kubectl get pvc/$i -o=jsonpath='{.spec.volumeName}' | xargs -I {} kubectl get pv {} -o=jsonpath='{.spec.csi.volumeHandle}' | cut -d '-' --fields=6-10`
    echo "Ceph RBD is $PV..."
    kubectl -n rook-ceph exec -it "$TOOLS" -- sh -c "DEV=\$(rbd map replicapool/$PV) && mkdir -p /tmp/rbd && mount \$DEV /tmp/rbd && rm -rf /tmp/rbd/* && cp -rvapf /mnt/nfs/$FOLDER/$i/* /tmp/rbd/ && cd /tmp; umount /tmp/rbd && rbd unmap \$DEV"
done
