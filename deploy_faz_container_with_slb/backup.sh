#!/bin/bash -x 
#ssh-keygen -t rsa -N '' -f ./id_rsa -q -y
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
kubectl cp ./id_rsa $podname:/etc/cert/ssh/
kubectl cp ./clibackup.sh $podname:/tmp/clibackup.sh
kubectl exec -it $podname  -- /bin/bash -c "/tmp/clibackup.sh"
#cat clibackup.sh
#echo execute backup  all-settings  scp 119.3.33.95 ./faz1.backup root id_rsa  | cli
kubectl exec -it $podname -- /bin/bash -c "echo get system backup status | cli"
sleep 5 
ssh root@119.3.33.95  ls -al *.backup


