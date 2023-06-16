#!/bin/bash -x

fmgdns="fmgweb.eastasia.cloudapp.azure.com"
service_name="fmgcontainerhttps"
namespace="fortimanager"

filename="fmgclusteriphttphttps.yml"
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
    app: fortimanager
  type: ClusterIP
EOF
kubectl apply -f $filename -n $namespace
 
filename="fmgingress_port_80.yml"

cat << EOF > $filename 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fmg-ingress
  annotations:
    #kubernetes.io/ingress.class: kong
    cert-manager.io/cluster-issuer: "selfsigned-issuer"
    # konghq.com/strip-path: "true"
    # konghq.com/https-redirect-status-code: "301"
    konghq.com/protocol: "https"
    # konghq.com/override: "https-only"
spec:
  ingressClassName: "kong"
  tls:
  - hosts:
    - $fmgdns
    secretName: fortimanager-tls
  rules:
  - host: $fmgdns
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

kubectl get ingress -n $namespace
while [[ -z $(kubectl get ingress -n $namespace -o jsonpath='{.items[].status.loadBalancer.ingress[0].ip}') ]]; do echo "Waiting for IP..."; sleep 10; done; curl -k https://fmgweb.eastasia.cloudapp.azure.com/
