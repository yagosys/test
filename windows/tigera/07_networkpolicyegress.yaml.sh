#!/bin/bash -xe
filename="globalNetworkPolicyEgress.yml"
tier="fortigate"
addrgrpname="fortigate.production-microservice1"
kubectl get tier $tier || echo "no tier fortigate exist"
cat << EOF > $filename
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  labels:
    projectcalico.org/tier: fortigate
  name: $addrgrpname
spec:
  tier: $tier
  egress:
    - action: Allow
  selector: env == 'prod' 
  types:
    - Egress
EOF
kubectl apply -f $filename

kubectl create deployment nginx --image=nginx --replicas=2 
kubectl rollout status deployment nginx 
kubectl label pods -l app=nginx env=prod
#kubectl label deployment nginx  env=prod
ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com show firewall addrgrp $addrgrpname
