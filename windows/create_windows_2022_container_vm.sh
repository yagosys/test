#!/bin/bash -x
#VNET_NAME=$(az network vnet list -g $CLUSTER_RG --query [0].name -o tsv)
#SUBNET_NAME=$(az network vnet subnet list -g $CLUSTER_RG --vnet-name $VNET_NAME --query [0].name -o tsv)
#SUBNET_ID=$(az network vnet subnet show -g $CLUSTER_RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv)
PUBLIC_IP_ADDRESS="myVMPublicIP"
LOCATION="westus"
NSG_NAME="wandynsg"
CLUSTER_RG="wanyvm"
VNET_NAME="wandyvnet"
SUBNET_NAME="vmsubnet"
VM_NAME="myVM"
az group create --name $CLUSTER_RG --location  $LOCATION
az network nsg create --name wandynsg --resource-group $CLUSTER_RG  --location $LOCATION
az network vnet create --name $VNET_NAME --resource-group $CLUSTER_RG --location $LOCATION --address-prefix 10.0.0.0/16
az network vnet subnet create --name $SUBNET_NAME --resource-group $CLUSTER_RG --vnet-name $VNET_NAME --address-prefix 10.0.0.0/24

az vm create \
    --resource-group $CLUSTER_RG \
    --name $VM_NAME \
    --image win2022datacenter \
    --location $LOCATION \
    --admin-username adminuser \
    --admin-password Welcome.123456!#  \
    --subnet $SUBNET_NAME \
    --vnet-name $VNET_NAME \
    --nic-delete-option delete \
    --size Standard_D4_v4 \
    --os-disk-delete-option delete \
    --nsg $NSG_NAME \
    --public-ip-address $PUBLIC_IP_ADDRESS \
    --query publicIpAddress -o tsv \
    --custom-data cloud-init.txt


    az vm extension set \
  --resource-group $CLUSTER_RG \
  --vm-name myVM \
  --name CustomScriptExtension \
  --publisher Microsoft.Compute \
  --settings '{"fileUris": ["https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/install.ps1"],"commandToExecute": "powershell -File install.ps1"}'


az network nsg rule create \
 --name tempRDPAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 100 \
 --destination-port-range 3389 \
 --protocol Tcp \
 --description "Temporary RDP access to Windows nodes"

az network nsg rule create \
 --name tempSSHAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 101 \
 --protocol Tcp \
 --destination-port-range 22 

az network nsg rule create \
 --name tempHTTPSAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 102 \
 --protocol Tcp \
 --destination-port-range 443 

az network nsg rule create \
 --name tempDockerSAccess \
 --resource-group $CLUSTER_RG \
 --nsg-name $NSG_NAME \
 --priority 103 \
 --protocol Tcp \
 --destination-port-range 2375


nicResourceIds=$(az vm show --name $VM_NAME --resource-group $CLUSTER_RG --query 'networkProfile.networkInterfaces[].id' --output tsv)
for nicResourceId in $nicResourceIds; do   az network nic update --ids $nicResourceId --network-security-group $NSG_NAME; done

vmip=$(az vm list-ip-addresses -g wanyvm)
echo $vmip
