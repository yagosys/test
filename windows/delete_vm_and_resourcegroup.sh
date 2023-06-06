#!/bin/bash -x
CLUSTER_RG="wanyvm"
VM_NAME="myVM"
az vm delete \
 --resource-group $CLUSTER_RG \
 --name myVM -y

az group delete --name $CLUSTER_RG -y
