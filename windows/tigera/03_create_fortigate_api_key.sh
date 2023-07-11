#!/bin/bash -xe
key=$(ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com execute api-user generate-key tigera | grep  "New API key" | cut -d ":" -f 2 | tr -d " ")
echo $key
kubectl create secret generic fortigate \
-n tigera-firewall-controller \
--from-literal=fortigate-key=$key
kubectl get secret fortigate -n tigera-firewall-controller -o yaml | grep fortigate-key 
