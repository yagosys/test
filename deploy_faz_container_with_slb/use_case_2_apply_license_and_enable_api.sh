#!/bin/bash -x
kubectl create -f ./pvc.yaml
kubectl create -f ./fazcontainer.yaml
kubectl create -f ./fazsvclb443.yaml
namespace="default"

function add_license_from_homedirectory_and_setup_admin_password() {
licfile=$1
[[ $licfile == "" ]] && licfile="VMTM23008295.lic"
if [ ! -f "$HOME/$licfile" ]; then
    echo "File $HOME/$licfile does not exist. put a license file in $HOME"
    exit 1
fi
adminpassword="Welcome.123"
podname=$(kubectl get -n $namespace pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
echo $podname

echo cp license to container
kubectl cp $HOME/$licfile $namespace/$podname:/tmp/$licfile
sleep 5
#echo config admin password to $adminpassword
#kubectl -n $namespace exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli'
echo add license from $licfile

kubectl -n $namespace exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/'$licfile')\"" | cli' | tee -a $filename
}

function enable_api_for_admin() {
podname=$(kubectl get -n $namespace pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
service_name="fazcontainerhttps"
ip=$(kubectl get -n $namespace svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
kubectl -n $namespace exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set rpc-permit read-write\n end\n" | cli'
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
curl -k -d @request.json -H "Content-Type: application/json" -X POST https://$ip/jsonrpc | tee -a $filename
}

function wait_for_faz_ready() {
service_name="fazcontainerhttps"
while true; do
    ip=$(kubectl get -n $namespace svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
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
  kubectl get -n $namespace pod  -l app=fortianalyzer
done
}

current_date=$(date '+%Y-%m-%d-%H-%M')
filename="use_case_2_${current_date}.txt"
echo start deploy faz at $(date) > $filename
wait_for_faz_ready && 
echo faz ready at $(date) | tee -a $filename
kubectl get -n $namespace pod -l app=fortianalyzer | tee -a $filename
echo start apply license | tee -a $filename
add_license_from_homedirectory_and_setup_admin_password &&
echo after apply license,faz will restart , wait for faz ready again  | tee -a $filename
echo sleep 60 for faz to reboot | tee -a $filename 
sleep 60
wait_for_faz_ready
echo "license applied" | tee -a  $filename
echo faz ready again after reboot at $(date) | tee -a $filename
kubectl get -n $namespace pod -l app=fortianalyzer | tee -a $filename
podname=$(kubectl get -n $namespace pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
echo "$pod_name user admin has password $adminpassword" >> $filename

echo "use cli to get system status" >> $filename
kubectl -n $namespace exec -it $podname -- /bin/bash -c 'echo -e "get system status" | cli' | tee -a  $filename
kubectl -n $namespace exec -it $podname -- /bin/bash -c 'top -n 1' | tee -a  $filename

echo "start enable json rpc api for $podname" | tee -a  $filename

adminpassword="Welcome.123"
kubectl -n $namespace exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli' | tee -a $filename
enable_api_for_admin && echo "admin user json rpc api enable"| tee -a  $filename

for i in $(seq 1 5); do echo -e '\a'; sleep 1; done 

