#!/bin/bash -x
#record the time took from  create fmg to fmg able to accept log
#this will start from create storage for fmg and use curl to access fmg 443 port as end
kubectl create -f ./pvc.yaml
kubectl create -f ./myfmgcontainer.yaml
kubectl create -f ./fmgsvclb443.yaml
./check.sh usecase1
kubectl delete -f fmgsvclb443.yaml
kubectl delete -f ./myfmgcontainer.yaml
kubectl delete -f pvc.yaml

