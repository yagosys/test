#!/bin/bash -x
version=$1
[[ -z $version ]] && version="7.2.2"

applabel="fortimanager"
function get_devicelist_from_fmg() {
podname=$(kubectl get pod -l app=$applabel | grep Running | awk '{ print $1 }')
service_name="fmgcontainerhttps"
ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
#echo -e "config system admin user \n edit admin\n set rpc-permit read-write\n end\n" | cli
# Login and get session ID
session_id=$(curl -k -s -d '{"method":"exec","params":[{"url":"/sys/login/user","data":{"user":"admin","passwd":"Welcome.123"}}]}' -H "Content-Type: application/json" -X POST https://$ip/jsonrpc | jq -r .session)
echo $session_id

# Create the request JSON with the session ID
cat << EOF > request.json
{
  "method": "get",
  "params": [
    {
      "option": "{option}",
      "url": "/dvmdb/device/fgt"
    }
  ],
  "session": "$session_id",
  "id": 1
}
EOF

# Send the request
curl -k -d @request.json -H "Content-Type: application/json" -X POST https://$ip/jsonrpc
}

function wait_for_fmg_ready() {
service_name="fmgcontainerhttps"
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

function check_upgrade_result () {
podname=$(kubectl get pod -l app=$applabel | grep Running | awk '{ print $1 }')
echo $podname

echo 'diag cdb upgrade summary' | tee -a $filename
kubectl exec -it $podname -- /bin/bash -c 'echo -e "diag cdb upgrade summary \n" | cli'  | tee -a $filename
echo 'diag cdb  upgrade log' | tee -a $filename
kubectl exec -it $podname -- /bin/bash -c 'echo -e "diag cdb upgrade log \n" | cli'  | tee -a $filename
echo 'diag cdb upgrade check +all' | tee -a $filename
#kubectl exec -it $podname -- /bin/bash -c 'echo -e "diag cdb upgrade check +all\n" | cli'  | tee -a $filename

}
wait_for_fmg_ready
current_date=$(date '+%Y-%m-%d')
filename="usecase_3_${current_date}.txt"
echo "get device list from current version of fmg" > $filename
podname=$(kubectl get pod -l app=$applabel | grep Running | awk '{ print $1 }')

get_devicelist_from_fmg | tee -a $filename

echo "start upgrade to version $version"

kubectl set image deployment/$applabel-deployment $applabel=fortinet/$applabel:$version | tee -a $filename
echo sleep 30 for it get ready
sleep 30

podname=$(kubectl get pod -l app=$applabel | grep 0/1 | awk '{ print $1 }')
while true; do
  if kubectl get pod $podname | grep -q "1/1"; then
    wait_for_fmg_ready
    echo "upgraded to $version done" | tee -a $filename
    break
  fi
  sleep 5
done

get_devicelist_from_fmg | tee -a $filename
check_upgrade_result 


