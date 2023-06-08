#!/bin/bash -x
kubectl delete -f fmgsvclb443.yaml
kubectl delete -f fmgcontainer.yaml
kubectl delete -f pvc.yaml
