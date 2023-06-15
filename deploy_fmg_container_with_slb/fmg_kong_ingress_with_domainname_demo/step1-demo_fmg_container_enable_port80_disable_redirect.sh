#!/bin/bash -x
namespace="default"
applabel="fortimanager"

cat << EOF > pvc.yml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: fmgdata
spec:
  storageClassName: managed-premium
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 7Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: default
  name: fmgvar
spec:
  storageClassName: managed-premium
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 7Gi
EOF

kubectl apply -f pvc.yml


filename="fmgcontainer.yml"

cat << EOF > $filename
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fortimanager-deployment
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fortimanager
  template:
    metadata:
      labels:
        app: fortimanager
    spec:
      nodeSelector:
        linux: "true"
      containers:
        - name: fortimanager
          image: fortinet/fortimanager:7.4
          resources:
            limits:
              cpu: "4"
              memory: "8000Mi"
            requests:
              cpu: "4"
              memory: "8000Mi"
          ports:
            - containerPort: 541
            - containerPort: 443
            - containerPort: 22
            - containerPort: 23
            - containerPort: 8888
            - containerPort: 8889
            - containerPort: 8890
            - containerPort: 8080
            - containerPort: 8080
            - containerPort: 8123
            - containerPort: 9009
            - containerPort: 9000
            - containerPort: 8793
            - containerPort: 9999
            - containerPort: 8443
            - containerPort: 514
            - containerPort: 514
              protocol: UDP
            - containerPort: 26443
            - containerPort: 161
              protocol: UDP
          securityContext:
            capabilities:
              add:
                - ALL
          readinessProbe:
            tcpSocket:
              port: 443
            initialDelaySeconds: 240
            periodSeconds: 10
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /
              port: 443
              scheme: HTTPS
            initialDelaySeconds: 480
            periodSeconds: 10
            failureThreshold: 3
          volumeMounts:
            - name: var-fmgt100
              mountPath: /var
            - name: data-fmgt100
              mountPath: /data
      volumes:
        - name: var-fmgt100
          persistentVolumeClaim:
            claimName: fmgvar
        - name: data-fmgt100
          persistentVolumeClaim:
            claimName: fmgdata
EOF

kubectl apply -f $filename && 

kubectl rollout status deployment fortimanager-deployment 

podname=$(kubectl get pod -l app=$applabel -n $namespace | grep Running | awk '{ print $1 }') &&  \

kubectl exec -it $podname -n $namespace -- /bin/bash -c 'echo -e "config system admin setting \n set http_port 80\n set admin-https-redirect disable\n end\n" | cli' 
