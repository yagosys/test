#!/bin/bash -xe
filename="tier.yml"
tier="fortigate"
cat << EOF > $filename
---
apiVersion: projectcalico.org/v3
kind: Tier
metadata:
  name: $tier
spec:
  order: 500
EOF
kubectl apply -f $filename
kubectl get tier


