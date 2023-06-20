#!/bin/bash -x
licfilename="FMG-VMTM23008863.lic"
namespace="fortimanager"
applabel="fortimanager"

function config_admin_password() {
adminpassword="Welcome.123"
podname=$(kubectl get pod -l app=$applabel -n $namespace | grep Running | awk '{ print $1 }')
echo $podname
echo config admin password to $adminpassword
kubectl exec -it $podname -n $namespace -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli'
}

function add_license_from_homedirectory() {
licfile=$1
[[ $licfile == "" ]] && licfile=$licfilename
if [ ! -f "$HOME/$licfile" ]; then
    echo "File $HOME/$licfile does not exist. put a license file in $HOME"
    exit 1
fi
podname=$(kubectl get pod -l app=$applabel -n $namespace | grep Running | awk '{ print $1 }')
echo $podname

echo cp license to container
kubectl cp $HOME/$licfile $namespace/$podname:/tmp/$licfile
sleep 5
echo add license from $licfile
kubectl exec -it $podname -n $namespace -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/'$licfile')\"" | cli'
}

kubectl create namespace  $namespace



cat << EOF > pvc.yml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
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
  name: fmgvar
spec:
  storageClassName: managed-premium
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 7Gi
EOF

kubectl apply -f pvc.yml -n $namespace


filename="fmgcontainer.yml"

cat << EOF > $filename
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $applabel-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $applabel
  template:
    metadata:
      labels:
        app: $applabel
    spec:
      nodeSelector:
        linux: "true"
      containers:
        - name: $applabel
          image: fortinet/$applabel:7.4
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

kubectl apply -f $filename -n $namespace && 

kubectl rollout status deployment $applabel-deployment  -n $namespace

podname=$(kubectl get pod -l app=$applabel -n $namespace | grep Running | awk '{ print $1 }') &&  \
kubectl exec -it $podname -n $namespace -- /bin/bash -c 'echo -e "config system admin setting \n set http_port 80\n set admin-https-redirect disable\n end\n" | cli' 
config_admin_password

add_license_from_homedirectory

kubectl rollout status deployment $applabel-deployment -n $namespace
echo wait 60 seconds for fmg to reboot and apply license
sleep 60
kubectl rollout status deployment $applabel-deployment -n $namespace
