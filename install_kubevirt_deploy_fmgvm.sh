#!/bin/bash -xe
if sudo pwd ; then echo you are sudoer; fi

export VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | sort -r | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
echo $VERSION
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml

kubectl rollout status deployment -n kubevirt && 
kubectl rollout status ds -n kubevirt && 
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"

while true; do
  PHASE=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o jsonpath="{.status.phase}")
  if [ "$PHASE" == "Deployed" ]; then
    break
  else
    echo "Waiting for status.phase to become Deployed, current phase: $PHASE"
    sleep 10
  fi
done
echo "Status.phase is now Deployed"


echo  install virtcl client  
#export KUBEVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | jq -r .tag_name)
export KUBEVIRT_VERSION=$VERSION
wget -O ~/virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64
chmod +x ~/virtctl
sudo install ~/virtctl /usr/local/bin

echo install krew

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" >> ~/.bashrc
echo export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
#kubectl krew install virt


echo #install localhost storageclass
#kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
#kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
#kubectl rollout status deployment/local-path-provisioner  -n local-path-storage


echo  intall data importor 
export VERSION=$(curl -Ls https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -m 1 -o "v[0-9]\.[0-9]*\.[0-9]*")
echo $VERSION
kubectl apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml && 
kubectl -n cdi scale deployment/cdi-operator --replicas=1 && 
kubectl -n cdi rollout status deployment/cdi-operator 

echo - install crd for cdi 
kubectl apply -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
kubectl wait -n cdi --for=jsonpath='{.status.phase}'=Deployed cdi/cdi --timeout=600s && 
kubectl -n cdi get pods
sleep 10 

cat << END > startup-script
#cloud-config
hostname: fmg
ssh_authorized_keys:
  - $(cat ~/.ssh/id_rsa.pub)
END

kubectl create secret generic fmg-cloudconfig --from-file=userdata=startup-script

cat << EOF  > fmgdv.yml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "fmg"
spec:
  source:
    http:
      #url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmg707.qcow2" # S3 or GCS
      #url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmgoracle722.qcow2" # S3 or GCS
      url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/fmgibm707.qcow2" # S3 or GCS
      #url: "https://wandy-public-7326-0030-8177.s3.ap-southeast-1.amazonaws.com/faz74.qcow2" # S3 or GCS
  pvc:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: "5000Mi"
EOF

kubectl apply -f fmgdv.yml

cat << EOF > fmglogpvc.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: log
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 7Gi
EOF
kubectl apply -f fmglogpvc.yml

echo create fmgvm 

kubectl get pv && kubectl get pvc 


cat << EOF  > fmgvm.yml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  labels:
    kubevirt.io/os: linux
  name: fmg
spec:
  running: true
  template:
    metadata:
      creationTimestamp: null
      labels:
        kubevirt.io/domain: fmg
        app: fmg
    spec:
      nodeSelector: #nodeSelector matches nodes where performance key has high as value.
        nested: "true"
      domain:
        cpu:
          cores: 4
        devices:
          disks:
          - disk:
              bus: virtio
            name: disk0
          - disk:
              bus: virtio
            name: disk1
          - cdrom:
              bus: sata
              readonly: true
            name: cloudinitdisk
        resources:
          requests:
            memory: 8000M
      readinessProbe:
        tcpSocket:
          port: 443
        initialDelaySeconds: 180
        periodSeconds: 10
        failureThreshold: 3
      volumes:
      - name: disk0
        persistentVolumeClaim:
          claimName: fmg
      - name: disk1
        persistentVolumeClaim:
          claimName: log
      - cloudInitNoCloud:
          secretRef:
            name: fmg-cloudconfig
#          userData: |
#            #cloud-config
#            hostname: fmg
#            ssh_pwauth: True
#            disable_root: false
#            ssh_authorized_keys:
#            - ssh-rsa YOUR_SSH_PUB_KEY_HERE
        name: cloudinitdisk
EOF

sleep 60
kubectl create -f fmgvm.yml  &&

POD_LABEL_SELECTOR="app=fmg"

check_pod_status() {
  local pod_status=$(kubectl get pod -l "$POD_LABEL_SELECTOR" -o jsonpath='{.items[0].status.phase}')
  if [ "$pod_status" = "Running" ]; then
    return 0
  else
    return 1
  fi
}

wait_for_pod_running() {
  until check_pod_status; do
    echo "Waiting for the pod to be in 'Running' state..."
    sleep 5
  done
}

wait_for_pod_running

echo "The pod is now in 'Running' state."


port="443"
nodeport="30443"
cat << EOF > fmgNodePort.yml
apiVersion: v1
kind: Service
metadata:
  name: fmg$port
spec:
  type: NodePort
  selector:
    app: fmg # Replace this with the labels your pod has
  ports:
    - port: $port
      targetPort: $port
      nodePort: $nodeport
EOF
#kubectl apply -f fmgNodePort.yml && 

#echo deploy fmg707 contaier 

cat << EOF > fmgcontainer.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fortimanager-deployment
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
      containers:
        - name: fortimanager
          image: fortinet/fortimanager:7.0.7
          ports:
            - containerPort: 541
            - containerPort: 443
            - containerPort: 22
            - containerPort: 23
            - containerPort: 8888
            - containerPort: 8889
            - containerPort: 8890
            - containerPort: 8080
            - containerPort: 161
              protocol: UDP
          securityContext:
            capabilities:
              add:
                - ALL
          readinessProbe:
            tcpSocket:
              port: 443
            initialDelaySeconds: 180
            periodSeconds: 10
            failureThreshold: 3
          volumeMounts:
            - name: var-fmgt100
              mountPath: /var
            - name: data-fmgt100
              mountPath: /data
      volumes:
        - name: var-fmgt100
          hostPath:
            path: /var/fmg/var_fmgt100
        - name: data-fmgt100
          hostPath:
            path: /var/fmg/data_fmgt100
EOF
#kubectl apply -f  fmgcontainer.yml 

echo create k8s connector
kubectl -n kube-system create serviceaccount ftntconnector  
kubectl create clusterrolebinding service-admin --clusterrole=cluster-admin --serviceaccount=kube-system:ftntconnector  
kubectl create token ftntconnector -n kube-system  

podname=$(kubectl get pod -l app=fmg | grep Running | awk '{ print $1 }')
fmgip=$(kubectl get pod $podname -o jsonpath='{.status.podIP}')
echo fmg pod ip = $fmgip

echo deploymentcompleted
