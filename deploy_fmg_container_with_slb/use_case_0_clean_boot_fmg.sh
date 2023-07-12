#!/bin/bash -x
kubectl create -f ./pvc.yaml
kubectl create -f ./fmgcontainer.yaml
cd nginx_ingress_demo_fmg
./04_create_internal_lb_for_fmg_443_80.sh default

