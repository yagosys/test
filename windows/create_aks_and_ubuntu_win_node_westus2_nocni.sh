#!/bin/bash -xe
[[ -z $1 ]] && LOCATION="westus2" || LOCATION=$1
[[ -z $2 ]] && INSTANCETYPE="Standard_D8s_v4" || INSTANCETYPE=$2
#LOCATION="westus"
RESOURCEGROUP="wandyaks"
#INSTANCETYPE="Standard_B4s_v4"
#INSTANCETYPE="Standard_D8s_v4"
clustername="myAKSCluster"
PUBLICIPNAME="fmgpublicip"
cni_type="none"
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
    --network-plugin $cni_type \
    --max-pods 250 

#az aks nodepool add \
#    --resource-group $RESOURCEGROUP \
#    --cluster-name myAKSCluster \
#    --os-type Windows \
#    --os-sku Windows2022 \
#    --node-vm-size $INSTANCETYPE \
#    --name npwin \
#    --labels windows=true \
#    --labels kubernetes.io/os=windows \
#    --labels node.kubernetes.io=windows \
#    --node-count 1 &&
#
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

#
function create_public_ip_for_fmg() {
az network public-ip create \
    --resource-group $RESOURCEGROUP \
    --name $PUBLICIPNAME \
    --sku Standard \
    --allocation-method static
az network public-ip show --resource-group $RESOURCEGROUP --name $PUBLICIPNAME --query ipAddress --output tsv
}

#create_public_ip_for_fmg
CLIENT_ID=$(az aks show --name $clustername --resource-group $RESOURCEGROUP --query identity.principalId -o tsv)
RG_SCOPE=$(az group show --name $RESOURCEGROUP --query id -o tsv)
az role assignment create \
    --assignee ${CLIENT_ID} \
    --role "Network Contributor" \
    --scope ${RG_SCOPE}

