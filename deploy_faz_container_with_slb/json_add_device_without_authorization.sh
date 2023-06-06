fgtip=$1
fgtsn=$2
platform_str=$3
fgtpassword=$4
[[ $fgtip=="" ]] && fgtip="8.217.52.255"
[[ $fgtsn=="" ]] && fgtsn="FGTALILAS4G7QE2D"
[[ $platform_str=="" ]] && platform_str="FortiGate-VM64-ALI"
[[ $fgtpassword=="" ]] && fgtpassword="Welcome.123"

#https://docs.ansible.com/ansible/latest/collections/fortinet/fortimanager/fmgr_dvm_cmd_add_device_module.html
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
service_name="fazcontainerhttps"
ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
session_id=$(curl -k -s -d '{"method":"exec","params":[{"url":"/sys/login/user","data":{"user":"admin","passwd":"Welcome.123"}}]}' -H "Content-Type: application/json" -X POST https://$ip/jsonrpc | jq -r .session)

# Create the request JSON with the session ID
cat << EOF > request.json
{
"method": "exec",
  "params": [
    {
      "data": {
        "adom": "root",
        "device": {
          "adm_pass": [
            "$fgtpassword"
          ],
          "adm_usr": "admin",
          "desc": "FortiGate-VM64-ALI",
          "device action": "string",
          "faz.quota": 0,
          "ip": "$fgtip",
          "meta fields": "string",
          "mgmt_mode": "string",
          "mr": 0,
          "name": "string",
          "os_type": "0",
          "os_ver": "-1",
          "patch": 0,
          "platform_str": "$platform_str",
          "sn": "$fgtsn"
        },
        "flags": [
          "{option}"
        ],
        "groups": [
          {
            "name": "string",
            "vdom": "string"
          }
        ]
      },
      "url": "/dvm/cmd/add/device"
    }
  ],
  "session": "$session_id",
  "id": 1
}
EOF

# Send the request
curl -k -d @request.json -H "Content-Type: application/json" -X POST https://$ip/jsonrpc
