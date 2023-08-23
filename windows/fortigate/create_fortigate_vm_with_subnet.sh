#!/bin/bash -x
[[ -z $1 ]] && LOCATION="westus2" || LOCATION=$1
MyResourceGroup="MC_wandyaks_myAKSCluster_$LOCATION"
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
function create_vm() {
az network vnet subnet create --name $MySubnet -g $MyResourceGroup  --vnet-name $MyVNet --address-prefixes 10.225.0.0/24

az network nsg create --resource-group $MyResourceGroup --name $MyNSG 
az network nsg rule create --resource-group $MyResourceGroup --nsg-name $MyNSG --name MyNSGRule --priority 100 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges '*' --access Allow --protocol '*' --description "Allow all"

az network vnet subnet update --name $MySubnet --resource-group $MyResourceGroup --vnet-name $MyVNet --network-security-group $MyNSG

#az network public-ip create --resource-group $MyResourceGroup --name $MyPublicIP --sku Standard

az network nic create \
  --resource-group $MyResourceGroup \
  --name $MyNIC \
  --vnet-name $MyVNet \
  --subnet $MyInternalSubnet \
  --private-ip-address $fgtaddress

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
  

az network nsg rule create -g $MyResourceGroup --name "${MyVM}NSG-permitany" --nsg-name "${MyVM}NSG" --priority 100 --direction Inbound --access Allow --protocol "*" --source-address-prefixes "*" --source-port-ranges "*" --destination-address-prefixes "*" --destination-port-ranges "*"

}

function vmaddnic() {
az vm nic add \
  --resource-group $MyResourceGroup \
  --vm-name $MyVM \
  --nics $MyNIC

}

function stopvm() {
az vm deallocate \
--resource-group $MyResourceGroup \
--name $MyVM
}

function startvm() {
az vm start \
--resource-group $MyResourceGroup \
--name $MyVM
}

function delvm(){
az vm delete -g $MyResourceGroup --name $MyVM
}

function create_udr_to_fortigate() {
az network route-table create \
  --name $MyRouteTable \
  --resource-group $MyResourceGroup \
  --location $LOCATION

az network route-table route create \
  --name $MyRoute \
  --resource-group $MyResourceGroup \
  --route-table-name $MyRouteTable \
  --address-prefix $MyRouteEntry \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address $fgtaddress 

az network vnet subnet update \
  --name $MyInternalSubnet \
  --resource-group $MyResourceGroup \
  --vnet-name $MyVNet \
  --route-table $MyRouteTable
}

create_vm
stopvm
vmaddnic
startvm
create_udr_to_fortigate
#delvm
ssh -o "StrictHostKeyChecking=no" azureuser@fgtvmtest1.$LOCATION.cloudapp.azure.com   < fgtuserdata.txt
