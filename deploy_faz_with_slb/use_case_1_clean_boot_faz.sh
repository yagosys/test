#!/bin/bash -x
#record the time took from  create faz to faz able to accept log
#this will start from create storage for faz and use curl to access faz 443 port as end
kubectl create -f fazlogpvc.yaml &&
kubectl create -f fazdv.yaml &&
kubectl create -f faz707vm.yaml &&
kubectl create -f fazvmhttps.yaml &&
./check.sh usercase1
kubectl delete -f faz707vm.yaml
kubectl delete pvc faz
kubectl delete pvc fazlogvm
kubectl delete -f fazvmhttps.yaml
kubectl delete -f fazlogpvc.yaml
kubectl delete -f fazdv.yaml
