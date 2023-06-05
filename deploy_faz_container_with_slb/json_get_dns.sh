podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
kubectl exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set rpc-permit read-write\n end\n" | cli'
#echo -e "config system admin user \n edit admin\n set rpc-permit read-write\n end\n" | cli
# Login and get session ID
session_id=$(curl -k -s -d '{"method":"exec","params":[{"url":"/sys/login/user","data":{"user":"admin","passwd":"Welcome.123"}}]}' -H "Content-Type: application/json" -X POST https://20.239.29.145/jsonrpc | jq -r .session)

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
curl -k -d @request.json -H "Content-Type: application/json" -X POST https://20.239.29.145/jsonrpc

