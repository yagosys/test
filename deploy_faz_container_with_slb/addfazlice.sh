#!/bin/bash -x
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
kubectl cp ~/test.lic $podname:/tmp/
kubectl exec -it $podname -- /bin/bash -c 'echo -e "export lic=$(cat /tmp/test.lic)"'
sleep 20
kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/test.lic)\"" | cli'
