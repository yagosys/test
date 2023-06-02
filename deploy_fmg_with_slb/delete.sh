#!/bin/bash -x 
kubectl delete -f fmgvmhttps.yaml
kubectl delete -f fmg707vm.yaml
kubectl delete pvc fmg
kubectl delete pvc fmglog
kubectl delete -f fmglogpvc.yaml
kubectl delete -f fmgdv.yaml

echo done

