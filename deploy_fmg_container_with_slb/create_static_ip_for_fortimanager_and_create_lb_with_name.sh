resourcegroup="wandyaks"
clustername="myAKSCluster"
az network public-ip create \
    --resource-group $resourcegroup \
    --name myAKSPublicIP \
    --sku Standard \
    --allocation-method static
az network public-ip show --resource-group $resourcegroup --name myAKSPublicIP --query ipAddress --output tsv
CLIENT_ID=$(az aks show --name $clustername --resource-group $resourcegroup --query identity.principalId -o tsv)
RG_SCOPE=$(az group show --name $resourcegroup --query id -o tsv)
az role assignment create \
    --assignee ${CLIENT_ID} \
    --role "Network Contributor" \
    --scope ${RG_SCOPE}

#public_ip=$(az network public-ip list -g wandyaks  --query "[?dnsSettings.domainNameLabel=='fmgweb']"  | jq -r .[0].ipAddress) && \
public_ip=$(az network public-ip list -g wandyaks --query "[?name=='myAKSPublicIP']" | jq -r .[0].ipAddress) && \
cat << EOF > fmglbwithstaticipanddomain.yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: wandyaks
    service.beta.kubernetes.io/azure-dns-label-name: fmgweb
  name: azure-load-balancer
  namespace: default
  name: fmgcontainerhttps
spec:
  externalTrafficPolicy: Local
  sessionAffinity: ClientIP
  ports:
  - port: 443
    name: webgui
    protocol: TCP
    targetPort: 443
  - port: 22
    name: ssh
    protocol: TCP
    targetPort: 22
  - port: 8888
    name: weba
    protocol: TCP
    targetPort: 8888
  - port: 8889
    name: webb
    protocol: TCP
    targetPort: 8889
  - port: 8890
    name: webc
    protocol: TCP
    targetPort: 8890
  - port: 8080
    name: soap
    protocol: TCP
    targetPort: 8080
  - port: 514
    name: oftpd
    protocol: TCP
    targetPort: 514
  - port: 541
    name: fgfm
    protocol: TCP
    targetPort: 541
  - port: 8793
    name: mast
    protocol: TCP
    targetPort: 8793
  - port: 8443
    name: webg
    protocol: TCP
    targetPort: 8443
  - port: 9999
    name: webh
    protocol: TCP
    targetPort: 9999
  - port: 161
    name: syslog
    protocol: UDP
    targetPort: 161
  selector:
    app: fortimanager
  type: LoadBalancer
  loadBalancerIP: $public_ip
EOF
kubectl create -f fmglbwithstaticipanddomain.yaml

