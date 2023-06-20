#!/bin/bash -x

ingressclass="nginx"
filename="fmgingress.yml"
cat << EOF > $filename

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fmg-ingress-nginx-external
  namespace: fortimanager
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
#    nginx.ingress.kubernetes.io/rewrite-target: /$2
#    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
#    nginx.ingress.kubernetes.io/secure-backends: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: $ingressclass
    cert-manager.io/cluster-issuer: selfsigned-issuer
spec:
#  ingressClassName: nginx
  tls:
  - hosts:
    - fmg.eastasia.cloudapp.azure.com
    secretName: fortimanager-tls-fmg
  rules:
  - host: fmg.eastasia.cloudapp.azure.com
    http:
      paths:
#      - path: /fmg(/|$)(.*)
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: fmglb443
            port:
              number: 80
EOF

kubectl apply -f $filename
kubectl describe ingress fmg-ingress-nginx-external -n fortimanager
