#!/bin/bash -x 
kubectl create -f fazlogpvc.yaml && 
kubectl create -f fazdv.yaml &&
kubectl create -f faz707vm.yaml && 
kubectl create -f fazvmhttps.yaml && 
./check.sh
