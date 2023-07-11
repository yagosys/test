#!/bin/bash -x

[[ -z $1 ]] && LOCATION="westus2" || LOCATION=$1
MyResourceGroup="MC_wandyaks_myAKSCluster_westus2"
MyVNet="aks-vnet-12723653"
MySubnet="externalSubnet"
MyPublicIP="fgtpublicip"
MyNSG="fgtpublicNSG"
MyVM="fortgate"
MyNIC="toaks"
MyInternalSubnet="aks-subnet"
MyRouteTable="tofortigate"
MyRoute="someroute"
fgtaddress="10.224.1.26"
MyRouteEntry="0.0.0.0/0"
MyDNSLabel="fgtvmtest1"
az vm create \
  --resource-group $MyResourceGroup \
  --name $MyVM \
  --image fortinet:fortinet_fortigate-vm_v5:fortinet_fg-vm_payg_2022:latest \
  --admin-username azureuser \
  --admin-password Welcome.123456 \
  --vnet-name $MyVNet \
  --subnet $MySubnet \
  --public-ip-sku Standard \
  --public-ip-address-dns-name $MyDNSLabel \
  --ssh-key-values $HOME/.ssh/id_rsa.pub \
  --custom-data fgtuserdata.txt

az vm deallocate \
--resource-group $MyResourceGroup \
--name $MyVM

az vm nic add \
  --resource-group $MyResourceGroup \
  --vm-name $MyVM \
  --nics $MyNIC

az vm start \
--resource-group $MyResourceGroup \
--name $MyVM

ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com   < fgtuserdata.txt
#diagnose sys session list | grep dnat
#key=$(ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com execute api-user generate-key tigera | grep  "New API key" | cut -d ":" -f 2 | tr -d " ")
echo $key
