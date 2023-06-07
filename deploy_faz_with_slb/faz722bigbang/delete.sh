#!/bin/bash -x
kubectl delete -f faz707vm.yaml
kubectl delete pvc faz
echo done

