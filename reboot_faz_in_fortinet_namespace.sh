#!/bin/bash -x
[[ -z $1 ]] && namespace="fortinet" || namespace=$1
echo $namespace 

touch fazbootlog
  echo restart faz deployment 
  kubectl rollout restart deployment/fortianalyzer-deployment -n $namespace | tee >> fazbootlog
  sleep 10 
while true ; do 
  while ! kubectl get pod -l app=fortianalyzer  -n $namespace | grep "1/1" | grep "Running" ; do echo "wait for pod ready"; sleep 10 ; done
  new_podname=$(kubectl get pod -l app=fortianalyzer  -n $namespace | grep "1/1" | awk '{print $1}')
  echo new pod $new_podname is ready | tee >> fazbootlog
 ./config_fmg_to_faz.sh | tee >> fazbootlog
  sleep 5
 kubectl exec -it po/$new_podname -n $namespace -- tail -n 5 /var/log/locallog/elog | tee >> fazbootlog;
 kubectl exec -it po/$new_podname -n $namespace -- bin/bash -c 'echo -e "diag dvm device list" | cli' ; 
 kubectl exec -it po/$new_podname -n $namespace -- bin/bash -c 'echo -e "diag debug application oftpd 8" | cli' ;
 kubectl exec -it po/$new_podname -n $namespace -- bin/bash -c 'echo -e "diag debug enable" | cli' ; 
 echo enable debug oftpd on $new_podname | tee >> fazbootlog
 sleep 5
 ./config_fmg_to_faz.sh
  echo sleep 100;
  sleep 100 ;
  echo restart faz deployment 
#  kubectl rollout restart deployment/fortianalyzer-deployment -n $namespace
  kubectl exec -it po/$new_podname -n $namespace -- bin/bash -c reboot | tee >> fazbootlog; 
  sleep 10 ;
done

