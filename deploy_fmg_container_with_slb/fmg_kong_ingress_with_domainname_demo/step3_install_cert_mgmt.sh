#!/bin/bash -x

kubectl get namespace cert-manager || kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml

kubectl rollout status deployment  -n cert-manager 
dnsname="fmgweb.eastasia.cloudapp.azure.com"
namespace="fortimanager"
filename="clusterissuer_fmg.yml"

cat << EOF > $filename
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}

EOF

kubectl apply -f $filename -n $namespace && echo okey

sleep 15

filename="certificate_fmg.yml"

cat << EOF > $filename
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: fortimanager-tls
spec:
  secretName: fortimanager-tls
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
  commonName: $dnsname
  dnsNames:
  - $dnsname
EOF
kubectl apply -f $filename -n $namespace


kubectl get certificate -n $namespace
kubectl get secret  -n $namespace
