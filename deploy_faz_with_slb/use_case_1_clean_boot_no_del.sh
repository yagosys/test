#!/bin/bash -x
#record the time took from  create faz to faz able to accept log
#this will start from create storage for faz and use curl to access faz 443 port as end
kubectl create -f cidatadv.yaml
kubectl create -f fazlogpvc.yaml &&
kubectl create -f fazdv.yaml &&
kubectl create -f faz707vm.yaml &&
kubectl create -f fazvmhttps.yaml &&
./check.sh usecase1
