#!/bin/bash -x 
resourcegroup="wandyaks"
clustername="myAKSCluster"
fmgdnslabel="fmgweb"
az network public-ip create \
    --resource-group $resourcegroup \
    --name fmgpublicip \
    --sku Standard \
    --allocation-method static
az network public-ip show --resource-group $resourcegroup --name fmgpublicip --query ipAddress --output tsv
CLIENT_ID=$(az aks show --name $clustername --resource-group $resourcegroup --query identity.principalId -o tsv)
RG_SCOPE=$(az group show --name $resourcegroup --query id -o tsv)
az role assignment create \
    --assignee ${CLIENT_ID} \
    --role "Network Contributor" \
    --scope ${RG_SCOPE}

public_ip=$(az network public-ip list -g $resourcegroup --query "[?name=='fmgpublicip']" | jq -r .[0].ipAddress) && \

echo $public_ip                                                                                  

PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$public_ip')].[id]" --output tsv)
echo $PUBLICIPID
az network public-ip update --ids $PUBLICIPID --dns-name $fmgdnslabel

kubectl get namespace kong || kubectl create -f all-in-one-dbless.yaml &&  echo okey 

filename="kongproxyfmg.yml"
cat << EOF > $filename
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
    service.beta.kubernetes.io/aws-load-balancer-type: nlb
    service.beta.kubernetes.io/azure-load-balancer-resource-group: $resourcegroup
    service.beta.kubernetes.io/azure-dns-label-name: fmgweb
    konghq.com/protocol: "https"
  name: kong-proxy-fmg
  namespace: kong
spec:
  loadBalancerIP: $public_ip
  ports:
  - name: proxy
    port: 80
    protocol: TCP
    targetPort: 8000
  - name: proxy-ssl
    port: 443
    protocol: TCP
    targetPort: 8443
  selector:
    app: proxy-kong
  type: LoadBalancer

EOF

kubectl create -f $filename && \
kubectl rollout status deployment ingress-kong -n kong
kubectl  get svc -n kong
echo fmgweb.eastasia.cloudapp.azure.com  
