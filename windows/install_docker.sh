ip=$(az vm list-ip-addresses -g wanyvm | jq -r .[].virtualMachine.network.publicIpAddresses[0].ipAddress)
echo $ip
ssh adminuser@$ip  "powershell -ExecutionPolicy Bypass -File C:\temp\install-docker-ce.ps1"
scp daemon.json adminuser@$ip:"C:/ProgramData/docker/config/daemon.json"
ssh adminuser@$ip  "powershell Restart-Service docker"
