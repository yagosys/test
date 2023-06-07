#!/bin/bash -x
kubectl delete -f faz707vm.yaml
kubectl delete pvc faz
kubectl delete pvc fazlogvm
kubectl delete pvc cidata
kubectl delete -f fazvmhttps.yaml
kubectl delete -f fazlogpvc.yaml
kubectl delete -f fazdv.yaml
kubectl delete -f cidatadv.yaml

echo done

