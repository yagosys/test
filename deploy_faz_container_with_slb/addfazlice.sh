#!/bin/bash -x
licfile="VMTM23008295.lic"
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
kubectl cp $HOME/$licfile $podname:/tmp/$licfile
sleep 20
kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/'$licfile')\"" | cli'
