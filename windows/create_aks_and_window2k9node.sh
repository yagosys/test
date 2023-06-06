#!/bin/bash -x
LOCATION="eastasia"
RESOURCEGROUP="wandyaks"
INSTANCETYPE="Standard_D4_v4"
az group create --name $RESOURCEGROUP --location $LOCATION 

WINDOWS_USERNAME='azureuser'
WINDOWS_PASSWORD='Welcome.123456!#'
az aks create \
    --resource-group $RESOURCEGROUP \
    --name myAKSCluster \
    --node-count 1 \
    --enable-addons monitoring \
    --windows-admin-username $WINDOWS_USERNAME \
    --windows-admin-password $WINDOWS_PASSWORD \
    --vm-set-type VirtualMachineScaleSets \
    --network-plugin azure &&  

az aks nodepool add \
    --resource-group $RESOURCEGROUP \
    --cluster-name myAKSCluster \
    --os-type Windows \
    --os-sku Windows2022 \
    --node-vm-size $INSTANCETYPE \
    --name npwin \
    --labels windows=true \
    --labels kubernetes.io/os=windows \
    --labels node.kubernetes.io=windows \
    --node-count 1 &&

az aks nodepool add \
    --resource-group $RESOURCEGROUP \
    --cluster-name myAKSCluster \
    --os-type Linux \
    --node-vm-size $INSTANCETYPE \
    --name ubuntu \
    --labels nested=true \
    --labels linux=true \
    --node-count 1 && 
 
az aks get-credentials -g $RESOURCEGROUP -n myAKSCluster --overwrite-existing
