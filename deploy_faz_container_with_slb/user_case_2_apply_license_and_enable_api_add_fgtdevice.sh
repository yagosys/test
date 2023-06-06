#!/bin/bash -x
kubectl create -f ./pvc.yaml
kubectl create -f ./fazcontainer.yaml
kubectl create -f ./fazsvclb443.yaml

function add_license_from_homedirectory_and_setup_admin_password() {
licfile=$1
[[ $licfile == "" ]] && licfile="VMTM23008295.lic"
if [ ! -f "$HOME/$licfile" ]; then
    echo "File $HOME/$licfile does not exist. put a license file in $HOME"
    exit 1
fi
adminpassword="Welcome.123"
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
echo $podname

echo cp license to container
kubectl cp $HOME/$licfile $podname:/tmp/$licfile
sleep 5
echo config admin password to $adminpassword
kubectl exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli'
echo add license from $licfile

kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/'$licfile')\"" | cli'
}

function wait_for_faz_ready() {
service_name="fazcontainerhttps"
while true; do
    ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$ip" || "$ip" == "<pending>" ]]; then
        echo "Waiting for IP..."
        sleep 10
    else
        echo "Public IP assigned: $ip"
        break
    fi
done

while true; do
  if nc -zv $ip 443 -w 60; then
    echo "Ping successful, breaking loop"
    curl -k -I https://$ip
    break
  fi
  sleep 2
  kubectl get pod  -l app=fortianalyzer
done
}

wait_for_faz_ready
add_license_from_homedirectory_and_setup_admin_password
echo after apply license,faz will restart , wait for faz ready again
wait_for_faz_ready

