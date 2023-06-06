#!/bin/bash -x
licfile="VMTM23008295.lic"
adminpassword="Welcome.123"
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
kubectl cp $HOME/$licfile $podname:/tmp/$licfile
sleep 5
kubectl exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli'
kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/'$licfile')\"" | cli'
