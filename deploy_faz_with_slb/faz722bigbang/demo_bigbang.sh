#!/bin/bash -x
kubectl delete -f faz707vm.yaml
kubectl delete pvc faz
echo done
kubectl create -f faz722dv.yaml
kubectl create -f faz722vm.yaml
./check usecase2

