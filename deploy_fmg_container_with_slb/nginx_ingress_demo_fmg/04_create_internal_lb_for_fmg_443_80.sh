#!/bin/bash -x
filename="fmglb443svc.yml"
[[ -z $1 ]] && namespace="fortimanager" || namespace=$1
cat << EOF > $filename
---
apiVersion: v1
kind: Service
metadata:
  annotations:
#    service.beta.kubernetes.io/azure-load-balancer-resource-group: wandyaks
#    service.beta.kubernetes.io/azure-dns-label-name: fmg
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
  name: fmglb443
  namespace: $namespace
spec:
  externalTrafficPolicy: Local
  sessionAffinity: ClientIP
  ports:
  - port: 443
    name: webgui
    protocol: TCP
    targetPort: 443
  - port: 80
    name: web
    protocol: TCP
    targetPort: 80
  selector:
    app: fortimanager
  type: LoadBalancer
EOF
kubectl apply -f $filename &&



while true; do
    ip=$(kubectl describe svc fmglb443 -n $namespace | grep -w 'LoadBalancer Ingress' | awk '{print $3}')

    if [[ -z "$ip" ]]; then
        echo "IP is empty, waiting for 10 seconds..."
        sleep 10
    else
        echo "IP assigned: $ip"
        break
    fi
done

 
