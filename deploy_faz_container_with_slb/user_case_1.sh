#!/bin/bash -x
#record the time took from  create faz to faz able to accept log
kubectl create -f ./pvc.yaml
kubectl create -f ./fazcontainer.yaml
kubectl create -f ./fazsvclb443.yaml
./check.sh
./delete.sh
