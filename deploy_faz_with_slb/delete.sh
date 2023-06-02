#!/bin/bash -x
kubectl delete -f faz707vm.yaml
kubectl delete pvc faz
kubectl delete pvc fazlog
kubectl delete -f fazvmhttps.yaml
kubectl delete -f fazlogpvc.yaml
kubectl delete -f fazdv.yaml

echo done

