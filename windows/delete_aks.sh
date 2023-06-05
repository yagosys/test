#!/bin/bash -xe
LOCATION="eastasia"
RESOURCEGROUP="wandyaks"
CLUSTERNAME="myAKSCluster"
NODENAME="npwin ubuntu"
echo "delete nodepool"
sleep 5

for node in $NODENAME; do
    az aks nodepool delete --resource-group "$RESOURCEGROUP" --cluster-name "$CLUSTERNAME" --name "$node"
done

echo "delete aks cluster $CLUSTERNAME"
sleep 5
az aks delete \
--resource-group $RESOURCEGROUP \
--name $CLUSTERNAME --yes  

