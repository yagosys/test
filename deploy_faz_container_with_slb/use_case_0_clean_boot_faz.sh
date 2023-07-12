#!/bin/bash -x
kubectl create -f ./pvc.yaml
kubectl create -f ./fazcontainer.yaml
cd nginx_ingress_demo_faz
./04_create_internal_lb_for_faz_443_80.sh default

