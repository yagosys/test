#!/bin/bash -xe
filename="fmgvmhttps.yml"
cat << EOF > $filename
apiVersion: v1
kind: Service
metadata:
  name: fmghttps
spec:
  externalTrafficPolicy: Cluster
  ports:
  - port: 443
    name: fmg
    protocol: TCP
    targetPort: 443
  selector:
    kubevirt.io/domain: fmg
  type: LoadBalancer
EOF
kubectl create -f $filename && 
while ! kubectl get svc fmghttps -o custom-columns=":.status.loadBalancer.ingress[0].ip" --no-headers=true ;do echo sleep 5 ;sleep 5; done
ip=$(kubectl get svc fmghttps -o custom-columns=":.status.loadBalancer.ingress[0].ip" --no-headers=true) 
echo $ip
curl -I -k https://$ip
