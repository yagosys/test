az group create --name myResourceGroup --location westus && 

WINDOWS_USERNAME=adminuser
WINDOWS_PASSWORD="Welcome.123456!#"
az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --windows-admin-username $WINDOWS_USERNAME \
    --windows-admin-password $WINDOWS_PASSWORD \
    --vm-set-type VirtualMachineScaleSets \
    --network-plugin azure && 

az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --os-type Windows \
    --os-sku Windows2019 \
    --name npwin \
    --node-count 1


 

