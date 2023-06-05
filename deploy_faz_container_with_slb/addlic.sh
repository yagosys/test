#!/bin/bash -x
echo "working echo -e "execute add-vm-license \"$lic\"" | cli"
kubectl cp ~/test.lic fortianalyzer-deployment-8675745f66-t5c99:/tmp/
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
service_name="fazcontainerhttps"
ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
kubectl exec -it $podname -- /bin/bash -c 'echo -e "export lic=$(cat /tmp/test.lic)"'
sleep 20
kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/test.lic)\"" | cli'
#kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$lic\"" | cli'
