#!/bin/bash -x
kubectl delete -f fmg707vm.yaml
kubectl delete pvc fmg
echo done
kubectl create -f fmg722dv.yaml
kubectl create -f fmg722vm.yaml
./check.sh usecase3

