#!/bin/bash -xe
kubectl delete secret fortigate -n tigera-firewall-controller
key=$(ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com execute api-user generate-key tigera | grep  "New API key" | cut -d ":" -f 2 | tr -d " ")
echo $key
kubectl create secret generic fortigate \
-n tigera-firewall-controller \
--from-literal=fortigate-key=$key
kubectl get secret fortigate -n tigera-firewall-controller -o yaml | grep fortigate-key 
podname=$(kubectl get pod -n tigera-firewall-controller -l k8s-app=tigera-firewall-controller | grep Running | cut -d ' ' -f 1)
kubectl delete po/$podname -n tigera-firewall-controller
kubectl get pod -n tigera-firewall-controller
