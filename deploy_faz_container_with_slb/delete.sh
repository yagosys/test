#!/bin/bash -x
kubectl delete -f fazsvclb443.yaml
kubectl delete -f fazcontainer.yaml
kubectl delete -f pvc.yaml
