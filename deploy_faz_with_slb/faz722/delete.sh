#!/bin/bash -x
kubectl delete -f faz722vm.yaml
kubectl delete pvc faz722
kubectl delete pvc faz2log
kubectl delete -f faz2vmhttps.yaml
kubectl delete -f faz2logpvc.yaml
kubectl delete -f faz722dv.yaml

echo done

