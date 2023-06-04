ip=$(az vm list-ip-addresses -g wanyvm | jq -r .[].virtualMachine.network.publicIpAddresses[0].ipAddress)
echo $ip
autossh -M 0 adminuser@$ip -o "ServerAliveInterval 60" -o "ServerAliveCountMax 3"
