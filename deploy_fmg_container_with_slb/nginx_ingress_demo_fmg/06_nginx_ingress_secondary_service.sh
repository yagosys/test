#!/bin/bash -x

resourcegroup="wandyaks"
fmgdnslabel="fmg"

public_ip=$(az network public-ip list -g $resourcegroup --query "[?name=='fmgpublicip']" | jq -r .[0].ipAddress) && \

filename="fmglbexternalsecondaryingress.yml"

cat << EOF > $filename

---
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: wandyaks
    service.beta.kubernetes.io/azure-dns-label-name: fmg
  name: ingress-secondary
  namespace: "ingress-nginx"
spec:
  selector:
    name: nginx-ingress-secondary
  type: LoadBalancer
  loadBalancerIP: $public_ip
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
    - name: https
      protocol: TCP
      port: 443
      targetPort: 443
EOF
kubectl create -f $filename

while true; do

ep=$(kubectl describe svc ingress-nginx-controller-admission -n ingress-nginx | grep Endpoints | awk '{ print $2 }')

    if [[ -z "$ep" ]]; then
        echo "EP is empty, waiting for 10 seconds..."
        sleep 10
    else
        echo "EP assigned: $ep"
        break
    fi
done
