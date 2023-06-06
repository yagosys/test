#!/bin/bash -x
#record the time took from  create faz to faz able to accept log
#this will start from create storage for faz and use curl to access faz 443 port as end
kubectl create -f ./pvc.yaml
kubectl create -f ./fazcontainer.yaml
kubectl create -f ./fazsvclb443.yaml
./check.sh usercase1
kubectl delete -f fazsvclb443.yaml
kubectl delete -f fazcontainer.yaml
kubectl delete -f pvc.yaml

