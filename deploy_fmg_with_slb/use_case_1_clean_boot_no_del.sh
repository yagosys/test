#!/bin/bash -x
#record the time took from  create fmg to fmg able to accept log
#this will start from create storage for fmg and use curl to access fmg 443 port as end
kubectl create -f fmgcidatadv.yaml
kubectl create -f fmglogpvc.yaml &&
kubectl create -f fmgdv.yaml &&
kubectl create -f fmg707vm.yaml &&
kubectl create -f fmgvmhttps.yaml &&
./check.sh usecase1
