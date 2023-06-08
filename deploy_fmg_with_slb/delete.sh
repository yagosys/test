#!/bin/bash -x
kubectl delete -f fmg707vm.yaml
kubectl delete pvc fmg
kubectl delete pvc fmglogvm
kubectl delete pvc cidata
kubectl delete -f fmgvmhttps.yaml
kubectl delete -f fmglogpvc.yaml
kubectl delete -f fmgdv.yaml
kubectl delete -f fmgcidatadv.yaml

echo done

