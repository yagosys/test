#!/bin/bash -xe
echo "delete nodepool"
sleep 5
az aks nodepool delete --resource-group k8s --cluster-name kubevirt --name nested  && echo done

echo "delete aks cluster kubevirt"
sleep 5
az aks delete \
--resource-group k8s \
--name kubevirt --yes  &&  echo done 

