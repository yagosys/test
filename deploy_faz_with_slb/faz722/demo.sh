#!/bin/bash -x 
kubectl create -f faz2logpvc.yaml && 
kubectl create -f faz722dv.yaml &&
kubectl create -f faz722vm.yaml &&
kubectl create -f faz2vmhttps.yaml
