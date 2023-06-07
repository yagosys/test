#!/bin/bash -x

kubectl create -f cidatadv.yaml
kubectl create -f fazlogpvc.yaml 
kubectl create -f fazdv.yaml 
kubectl create -f faz707vm.yaml 
kubectl create -f fazvmhttps.yaml 

applabel="faz"
service_name="fazvmhttps"

function add_license_from_homedirectory_and_setup_admin_password() {
licfile=$1
[[ $licfile == "" ]] && licfile="FAZ-VMTM23008181.lic"
if [ ! -f "$HOME/$licfile" ]; then
    echo "File $HOME/$licfile does not exist. put a license file in $HOME"
    exit 1
fi
adminpassword="Welcome.123"
podname=$(kubectl get pod -l app=$applabel | grep Running | awk '{ print $1 }')
echo $podname

echo config admin password to $adminpassword
echo add license from $licfile
lic=$(cat $HOME/$licfile)
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$ip  execute add-vm-license \"$lic\"  
}

function enable_api_for_admin() {
podname=$(kubectl get pod -l app=$applabel | grep Running | awk '{ print $1 }')
ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
kubectl exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set rpc-permit read-write\n end\n" | cli'
#echo -e "config system admin user \n edit admin\n set rpc-permit read-write\n end\n" | cli
# Login and get session ID
session_id=$(curl -k -s -d '{"method":"exec","params":[{"url":"/sys/login/user","data":{"user":"admin","passwd":"Welcome.123"}}]}' -H "Content-Type: application/json" -X POST https://$ip/jsonrpc | jq -r .session)

# Create the request JSON with the session ID
cat << EOF > request.json
{
  "method": "get",
  "params": [
    {
      "url": "/cli/global/system/dns"
    }
  ],
  "session": "$session_id",
  "id": 1
}
EOF

# Send the request
curl -k -d @request.json -H "Content-Type: application/json" -X POST https://$ip/jsonrpc
}

function wait_for_faz_ready() {
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
  kubectl get pod  -l app=$applabel
done
}

wait_for_faz_ready && 
add_license_from_homedirectory_and_setup_admin_password &&
echo after apply license,faz will restart , wait for faz ready again
echo sleep 60 for faz to reboot
sleep 60
wait_for_faz_ready
current_date=$(date '+%Y-%m-%d')
filename="usecase_2_${current_date}.txt"
echo "license applied" > $filename
podname=$(kubectl get pod -l app=$appleable | grep Running | awk '{ print $1 }')
echo "$pod_name user admin has password $adminpassword" >> $filename

echo "use cli to get system status" >> $filename

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@$ip 'get system status' | tee -a $filename

#echo "start enable json rpc api for $podname" >> $filename

#enable_api_for_admin && echo "admin user json rpc api enable" >> $filename
