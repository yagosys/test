#!/bin/bash -x
kubectl create -f fmgcontainer.yaml
kubectl create -f fmgsvcslb443.yaml
./check.sh
#./delete.sh
