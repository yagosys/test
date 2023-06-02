#!/bin/bash -x 
kubectl create -f fmglogpvc.yaml
kubectl create -f fmgdv.yaml
kubectl create -f fmg707vm.yaml
kubectl create -f fmgvmhttps.yaml
./check.sh

