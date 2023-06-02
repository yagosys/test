#!/bin/bash -x
kubectl create -f ./fazcontainer.yaml
kubectl create -f ./fazsvclb443.yaml
./check.sh
./delete.sh
