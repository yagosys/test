#!/bin/bash -x

fmgnamespace="fortinet"
kubectl delete -f fmgcluster.yaml -n $fmgnamespace
kubectl delete -f fmgcontainer.yaml -n $fmgnamespace
kubectl delete -f pvc_fmg.yaml -n $fmgnamespace
