#!/bin/bash -x

kubectl get namespace cert-manager || kubectl create namespace cert-manager 
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml

kubectl rollout status deployment  -n cert-manager 
fmgdnslabel="fmg"
location="eastasia"
namespace="fortimanager"
applabel="fortimanager"
dnsname="$fmgdnslabel.$location.cloudapp.azure.com"
tlscertificatename="$applabel-tls-fmg"
certname="selfsigned-issuer-fmg"

filename="clusterissuer_fmg.yml"

cat << EOF > $filename
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: $certname
spec:
  selfSigned: {}

EOF

sleep 15

kubectl apply -f $filename -n $namespace  && echo okey


filename="certificate_fmg_nginx.yml"

cat << EOF > $filename
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: $tlscertificatename
spec:
  secretName: $tlscertificatename
  duration: 2160h # 90d
  renewBefore: 360h # 15d
  issuerRef:
    name: $certname
    kind: ClusterIssuer
  commonName: $dnsname
  dnsNames:
  - $dnsname
EOF

sleep 15

kubectl apply -f $filename -n $namespace


kubectl get certificate -n $namespace
kubectl get secret  -n $namespace
