ip=$(az vm list-ip-addresses -g wanyvm | jq -r .[].virtualMachine.network.publicIpAddresses[0].ipAddress)
echo $ip
export DOCKER_HOST=tcp://$ip:2375
docker info
