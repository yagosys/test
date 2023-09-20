#!/bin/bash -x

#faznamespace="fortianalyzer"
faznamespace="fortinet"
#fmgnamespace="fortimanager"
fmgnamespace="fortinet"
kubectl delete -f fazcluster.yaml -n $faznamespace
kubectl delete -f fmgcluster.yaml -n $fmgnamespace
kubectl delete -f fazcontainer.yaml -n $faznamespace
kubectl delete -f fmgcontainer.yaml -n $fmgnamespace
kubectl delete -f pvc_faz.yaml -n $faznamespace
kubectl delete -f pvc_fmg.yaml -n $fmgnamespace
