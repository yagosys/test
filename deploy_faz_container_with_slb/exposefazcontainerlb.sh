#!/bin/bash -xe
filename="fazcontainerhttps.yml"
cat << EOF > $filename
apiVersion: v1
kind: Service
metadata:
  name: fazcontainerhttps
spec:
  externalTrafficPolicy: Local
  sessionAffinity: ClientIP
  ports:
  - port: 443
    name: webgui
    protocol: TCP
    targetPort: 443
  selector:
    app: fortianalyzer
  type: LoadBalancer
EOF
kubectl create -f $filename && 
sleep 10
while ! kubectl get svc fazcontainerhttps -o custom-columns=":.status.loadBalancer.ingress[0].ip" --no-headers=true ;do echo sleep 5 ;sleep 5; done
ip=$(kubectl get svc fazcontainerhttps -o custom-columns=":.status.loadBalancer.ingress[0].ip" --no-headers=true) 
echo $ip
curl --retry 3 -I -k https://$ip
