#!/bin/bash -x

fazdnslabel="fazweb"
location="eastasia"
fazdns="$fazdnslabel.$location.cloudapp.azure.com"
service_name="fazcontainerhttps"
namespace="fortianalyzer"
fazingressname="faz-ingress"
tlscertificatename="fortianalyzer-tls-faz"
certname="selfsigned-issuer-faz"
applabel="fortianalyzer"

filename="fazclusteriphttphttps.yml"
cat << EOF > $filename
---
apiVersion: v1
kind: Service
metadata:
  name: $service_name
spec:
  sessionAffinity: ClientIP
  ports:
  - port: 80
    name: web
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
    app: $applabel
  type: ClusterIP
EOF
kubectl apply -f $filename -n $namespace
 
filename="fazingress_port_80.yml"

cat << EOF > $filename 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $fazingressname
  namespace: $namespace
  annotations:
    kubernetes.io/ingress.class: kong
    cert-manager.io/cluster-issuer: $certname
spec:
  tls:
  - hosts:
    - $fazdns
    secretName: $tlscertificatename
  rules:
  - host: $fazdns
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: $service_name
            port:
              number: 80

EOF
kubectl apply -f $filename -n $namespace

while [[ -z $(kubectl get ingress -n fortianalyzer -o jsonpath='{.items[].status.loadBalancer.ingress[0].ip}') ]]; do echo "Waiting for IP..."; sleep 10; done; curl -k https://fazweb.eastasia.cloudapp.azure.com/

