az aks create \
--resource-group k8s \
--network-policy calico \
--network-plugin kubenet \
--node-vm-size Standard_B4ms \
--node-count 1 \
--name kubevirt --yes &&
az aks get-credentials -g k8s -n kubevirt --overwrite-existing
