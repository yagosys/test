#!/bin/bash -xe
filename="05_standard_ingress_deploy_without_lbsvc.yaml"
kubectl apply -f $filename
filename="nginx-ingress-secondary-controller.yaml"
kubectl apply -f $filename
