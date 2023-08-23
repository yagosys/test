#!/bin/bash -x
namespace="fortinet"
function config_fmg(){
podname=$(kubectl get pod -l app=fortianalyzer -n $namespace | grep Running |  grep "1/1"  | awk '{ print $1 }')
fazip=$(kubectl get pod $podname -n $namespace -o jsonpath='{.status.podIP}')
echo $fazip
podname=$(kubectl get pod -l app=fortimanager -n $namespace | grep Running | awk '{ print $1 }')
kubectl exec -it po/$podname -n $namespace -- bin/bash -c 'echo -e "config system locallog fortianalyzer setting\n set status realtime\n set reliable enable\n set server '$fazip'\n end\n" | cli' ;
kubectl exec -it po/$podname -n $namespace -- bin/bash -c 'echo -e "get system locallog fortianalyzer setting\n" | cli' ;
}

config_fmg
