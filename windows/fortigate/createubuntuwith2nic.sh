#!/bin/bash -x

# Set location
[[ -z $1 ]] && LOCATION="westus2" || LOCATION=$1

# Define all resource names
MyResourceGroup="MC_wandyaks_myAKSCluster_$LOCATION"
MyVNet="aks-vnet-$(date +%s)"
MySubnet="externalSubnet"
MySubnet2="internalSubnet"
MyPublicIP="ubuntu-public-ip"
MyNSG="allow-all-nsg"
MyVM="ubuntu-vm"
MyNIC1="primary-nic"
MyNIC2="secondary-nic"
MyDNSLabel="ubuntuvm-$(date +%s)"

# Create cloud-init file for Docker installation
cat > cloud-init.txt << 'EOF'
#cloud-config
package_update: true
package_upgrade: true
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - software-properties-common
runcmd:
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update -y
  - apt-get install -y docker-ce docker-ce-cli containerd.io
  - systemctl enable docker
  - usermod -aG docker azureuser
EOF

# 1. Create Resource Group
az group create \
  --name $MyResourceGroup \
  --location $LOCATION

# 2. Create Virtual Network
az network vnet create \
  --resource-group $MyResourceGroup \
  --name $MyVNet \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name $MySubnet \
  --subnet-prefixes 10.0.1.0/24

# 3. Create second subnet
az network vnet subnet create \
  --resource-group $MyResourceGroup \
  --vnet-name $MyVNet \
  --name $MySubnet2 \
  --address-prefixes 10.0.2.0/24

# 4. Create Network Security Group with ALLOW ALL rules
az network nsg create \
  --resource-group $MyResourceGroup \
  --name $MyNSG

# Allow ALL inbound traffic
az network nsg rule create \
  --resource-group $MyResourceGroup \
  --nsg-name $MyNSG \
  --name allow-all-inbound \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol '*' \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix '*' \
  --destination-port-range '*'

# Allow ALL outbound traffic
az network nsg rule create \
  --resource-group $MyResourceGroup \
  --nsg-name $MyNSG \
  --name allow-all-outbound \
  --priority 100 \
  --direction Outbound \
  --access Allow \
  --protocol '*' \
  --source-address-prefix '*' \
  --source-port-range '*' \
  --destination-address-prefix '*' \
  --destination-port-range '*'

# 5. Create Public IP
az network public-ip create \
  --resource-group $MyResourceGroup \
  --name $MyPublicIP \
  --sku Standard \
  --dns-name $MyDNSLabel

# 6. Create Primary NIC
az network nic create \
  --resource-group $MyResourceGroup \
  --name $MyNIC1 \
  --vnet-name $MyVNet \
  --subnet $MySubnet \
  --network-security-group $MyNSG \
  --public-ip-address $MyPublicIP

# 7. Create Secondary NIC
az network nic create \
  --resource-group $MyResourceGroup \
  --name $MyNIC2 \
  --vnet-name $MyVNet \
  --subnet $MySubnet2 \
  --network-security-group $MyNSG

# 8. Create Ubuntu VM with primary NIC
az vm create \
  --resource-group $MyResourceGroup \
  --name $MyVM \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --nics $MyNIC1 \
  --custom-data cloud-init.txt

# 9. Deallocate to add secondary NIC
az vm deallocate \
  --resource-group $MyResourceGroup \
  --name $MyVM

# 10. Add secondary NIC
az vm nic add \
  --resource-group $MyResourceGroup \
  --vm-name $MyVM \
  --nics $MyNIC2 \
  --primary-nic $MyNIC1

# 11. Start VM
az vm start \
  --resource-group $MyResourceGroup \
  --name $MyVM

# 12. Get connection information
PUBLIC_IP=$(az network public-ip show --resource-group $MyResourceGroup --name $MyPublicIP --query ipAddress -o tsv)
echo ""
echo "===================================================================="
echo "VM provisioning complete!"
echo "SSH command: ssh azureuser@$PUBLIC_IP"
echo "Docker will be automatically installed and ready for use"
echo "Web access: http://$PUBLIC_IP"
echo "===================================================================="

# 12 . add client Vm

az network public-ip create \
  --resource-group MC_wandyaks_myAKSCluster_westus2 \
  --name MyPublicIP2 \
  --sku Standard 

az network nic create \
  --resource-group MC_wandyaks_myAKSCluster_westus2 \
  --name MyClientNIC \
  --vnet-name aks-vnet-1746771132 \
  --subnet internalSubnet \
  --network-security-group allow-all-nsg \
  --public-ip-address MyPublicIP2

az vm create \
  --resource-group MC_wandyaks_myAKSCluster_westus2 \
  --name client \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --nics MyClientNIC

