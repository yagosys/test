#!/bin/bash -x

filename="fazingress"
cat << EOF > $filename

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: faz-ingress-nginx-external
  namespace: fortianalyzer
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
#    nginx.ingress.kubernetes.io/rewrite-target: /$2
#    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
#    nginx.ingress.kubernetes.io/secure-backends: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: selfsigned-issuer
spec:
        #  ingressClassName: nginx
  tls:
  - hosts:
    - faz.eastasia.cloudapp.azure.com
    secretName: fortianalyzer-tls-faz
  rules:
  - host: faz.eastasia.cloudapp.azure.com
    http:
      paths:
#      - path: /faz(/|$)(.*)
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: fazlb443
            port:
              number: 80
EOF

kubectl apply -f $filename
kubectl describe ingress faz-ingress-nginx-external -n fortianalyzer
