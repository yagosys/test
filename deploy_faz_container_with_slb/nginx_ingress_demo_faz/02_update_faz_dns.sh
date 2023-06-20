#!/bin/bash -x 
resourcegroup="wandyaks"
clustername="myAKSCluster"
fazdnslabel="faz"
location="eastasia"
az network public-ip create \
    --resource-group $resourcegroup \
    --name fazpublicip \
    --sku Standard \
    --allocation-method static
az network public-ip show --resource-group $resourcegroup --name fazpublicip --query ipAddress --output tsv
CLIENT_ID=$(az aks show --name $clustername --resource-group $resourcegroup --query identity.principalId -o tsv)
RG_SCOPE=$(az group show --name $resourcegroup --query id -o tsv)
az role assignment create \
    --assignee ${CLIENT_ID} \
    --role "Network Contributor" \
    --scope ${RG_SCOPE}

public_ip=$(az network public-ip list -g $resourcegroup --query "[?name=='fazpublicip']" | jq -r .[0].ipAddress) && \

PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$public_ip')].[id]" --output tsv)
echo $PUBLICIPID
az network public-ip update --ids $PUBLICIPID --dns-name $fazdnslabel
echo $public_ip                                                                                  

    #service.beta.kubernetes.io/azure-load-balancer-resource-group: $resourcegroup
    #service.beta.kubernetes.io/azure-dns-label-name: $fazdnslabel
echo $fazdnslabel.$location.cloudapp.azure.com 
