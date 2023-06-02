#!/bin/bash -x
kubectl delete -f fazsvcslb443.yaml
kubectl delete -f fazcontainer.yaml
