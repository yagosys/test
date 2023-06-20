#!/bin/bash -x

resourcegroup="wandyaks"
fazdnslabel="faz"

public_ip=$(az network public-ip list -g $resourcegroup --query "[?name=='fazpublicip']" | jq -r .[0].ipAddress) && \

filename="fazlbexternal.yml"

cat << EOF > $filename

apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-resource-group: wandyaks
    service.beta.kubernetes.io/azure-dns-label-name: faz
#    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.8.0
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  loadBalancerIP: $public_ip
  externalTrafficPolicy: Local
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - appProtocol: http
    name: http
    port: 80
    protocol: TCP
    targetPort: http
  - appProtocol: https
    name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  type: LoadBalancer
EOF

kubectl apply -f $filename 
sleep 30
kubectl rollout status deployment ingress-nginx-controller  -n ingress-nginx
kubectl logs deployment/ingress-nginx-controller -n ingress-nginx

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
