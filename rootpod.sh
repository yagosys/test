#!/bin/bash -xe
nodename=$(kubectl get node -l agentpool=nested --no-headers | awk '{ print $1}')

cat << EOF > privilegepod.yml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  hostPID: true
  nodeSelector:
    kubernetes.io/hostname: $nodename
  tolerations:
  - operator: "Exists"
  containers:
  - name: "netshoot"
    image: "nicolaka/netshoot"
    command: ["bash"]
    stdin: true
    tty: true
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /host
      name: host
  volumes:
  - name: host
    hostPath:
      path: /
EOF

kubectl apply -f privilegepod.yml
