az aks nodepool add \
--resource-group k8s \
--cluster-name kubevirt \
--name nested  \
--node-vm-size Standard_D4_v4 \
--labels nested=true \
--node-count 1 
