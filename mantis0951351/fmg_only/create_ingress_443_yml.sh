filename="clusterissuer_fmg.yml"
certname="selfsigned-issuer-fmg"

cat << EOF > $filename
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: $certname
spec:
  selfSigned: {}

EOF
filename="certificate_fmg_nginx.yml"
applabel="fortimanager"
certname="selfsigned-issuer-fmg"
tlscertificatename="$applabel-tls-fmg"
dnsname="fmgminikube"
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
ingressclass="nginx"
filename="fmgingress443.yml"
applabel="fortimanager"
certname="selfsigned-issuer-fmg"
tlscertificatename="$applabel-tls-fmg"
dnsname="fmgminikube"
cat << EOF > $filename

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fmg-ingress-nginx-external
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    kubernetes.io/ingress.class: $ingressclass
    cert-manager.io/cluster-issuer: selfsigned-issuer
spec:
  tls:
  - hosts:
    - $dnsname
    secretName: $tlscertificatename
  rules:
  - host: $dnsname
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: fmgcontainerhttps
            port:
              number: 80
EOF
