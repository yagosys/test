#!/bin/bash -x

faznamespace="fortinet"
kubectl delete -f fazcluster.yaml -n $faznamespace
kubectl delete -f fazcontainer.yaml -n $faznamespace
kubectl delete -f pvc_faz.yaml -n $faznamespace
