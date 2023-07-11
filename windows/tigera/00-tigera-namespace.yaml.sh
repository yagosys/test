#!/bin/bash -xe
kubectl get tigerastatus 
installed=$(kubectl get tigerastatus | grep True | wc  | awk '{ print $1}')
[[ $installed == '9' ]] && echo 'yes' || echo 'please install tiger first'
cat << EOF | kubectl apply -f - 
kind: Namespace
apiVersion: v1
metadata:
  name: tigera-firewall-controller
EOF
