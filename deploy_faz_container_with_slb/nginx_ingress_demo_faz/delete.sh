#!/bin/bash -x
[[ -z $1 ]] && location="westus2" || location=$1
[[ -z $2 ]] && fazdnslabel="faztest" || fazdnslabel=$2
kubectl delete -f 05_standard_ingress_deploy_without_lbsvc.yaml 
kubectl delete namespace fortianalyzer 
kubectl delete namespace ingress-nginx 
kubectl delete namespace cert-manager
#az network  public-ip delete  -g wandyaks -n fazpublicip
