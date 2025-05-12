#!/bin/bash 

# Global variables with default values using variable expansion
LOCATION="${LOCATION:-westus2}"
MyResourceGroup="${MyResourceGroup:-MC_wandyaks_myAKSCluster_${LOCATION}}"
MyVNet="${MyVNet:-aks-vnet-$(date +%y%d%h)}"
MySubnet="${MySubnet:-externalSubnet}"
MySubnet2="${MySubnet2:-internalSubnet}"
MyPublicIP="${MyPublicIP:-ubuntu-public-ip}"
MyPublicIP2="${MyPublicIP2:-client-public-ip}"
MyPublicIP3="${MyPublicIP3:-external-client-public-ip}"
MyNSG="${MyNSG:-allow-all-nsg}"
MyVM="${MyVM:-ubuntu-vm}"
MyNIC1="${MyNIC1:-primary-nic}"
MyNIC2="${MyNIC2:-secondary-nic}"
MyClientNIC="${MyClientNIC:-client-nic}"
MyExternalClientNIC="${MyExternalClientNIC:-external-client-nic}"
MyDNSLabel="${MyDNSLabel:-ubuntuvm-$(date +%s)}"
MyRouteTable="${MyRouteTable:-tofortigate}"
MyRoute="${MyRoute:-someroute}"
MyRouteEntry="${MyRouteEntry:-0.0.0.0/0}"
MycFOSContainerName="${MycFOSContainerName:-cfos}"
alias ssh="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

# Function to clean up resources on failure
cleanup() {
    echo "Cleaning up resources..."
    #az group delete --name "$MyResourceGroup" --yes --no-wait
    exit 1
}

# Trap errors and call cleanup
trap cleanup ERR

# Function to provision main Azure resources
provision_azure_resources() {
    # Override location if provided as argument
    LOCATION="${3:-${LOCATION}}"

    # Update dependent variables that rely on dynamic values
    MyResourceGroup="${MyResourceGroup:-MC_wandyaks_myAKSCluster_${LOCATION}}"
    MyVNet="${MyVNet:-aks-vnet-$(date +%y%d%h)}"
    MyDNSLabel="${MyDNSLabel:-ubuntuvm-$(date +%s)}"

    # Create cloud-init file for Docker installation and IP forwarding
    cat > cloud-init.txt << 'EOF'
#cloud-config
package_update: true
package_upgrade: true
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - software-properties-common
  - iptables
runcmd:
  - sysctl -w net.ipv4.ip_forward=1
  - echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update -y
  - apt-get install -y docker-ce docker-ce-cli containerd.io
  - systemctl enable docker
  - usermod -aG docker azureuser
  - iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
  - iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
  - echo docker login -u username -p password
  - echo docker pull interbeing/fos:x86v255
EOF

    # 1. Create Resource Group
    az group create \
        --name "$MyResourceGroup" \
        --location "$LOCATION" || { echo "Failed to create resource group"; exit 1; }

    # 2. Create Virtual Network
    az network vnet create \
        --resource-group "$MyResourceGroup" \
        --name "$MyVNet" \
        --address-prefixes 10.0.0.0/16 \
        --subnet-name "$MySubnet" \
        --subnet-prefixes 10.0.1.0/24 || { echo "Failed to create VNet"; exit 1; }

    # 3. Create second subnet
    az network vnet subnet create \
        --resource-group "$MyResourceGroup" \
        --vnet-name "$MyVNet" \
        --name "$MySubnet2" \
        --address-prefixes 10.0.2.0/24 || { echo "Failed to create second subnet"; exit 1; }

    # 4. Create Network Security Group with ALLOW ALL rules
    az network nsg create \
        --resource-group "$MyResourceGroup" \
        --name "$MyNSG" || { echo "Failed to create NSG"; exit 1; }

    # Allow ALL inbound traffic
    az network nsg rule create \
        --resource-group "$MyResourceGroup" \
        --nsg-name "$MyNSG" \
        --name allow-all-inbound \
        --priority 100 \
        --direction Inbound \
        --access Allow \
        --protocol '*' \
        --source-address-prefix '*' \
        --source-port-range '*' \
        --destination-address-prefix '*' \
        --destination-port-range '*' || { echo "Failed to create inbound NSG rule"; exit 1; }

    # Allow ALL outbound traffic
    az network nsg rule create \
        --resource-group "$MyResourceGroup" \
        --nsg-name "$MyNSG" \
        --name allow-all-outbound \
        --priority 100 \
        --direction Outbound \
        --access Allow \
        --protocol '*' \
        --source-address-prefix '*' \
        --source-port-range '*' \
        --destination-address-prefix '*' \
        --destination-port-range '*' || { echo "Failed to create outbound NSG rule"; exit 1; }

    # 5. Create Public IP
    az network public-ip create \
       --resource-group "$MyResourceGroup" \
        --name "$MyPublicIP" \
        --sku Standard \
        --dns-name "$MyDNSLabel" || { echo "Failed to create public IP"; exit 1; }

    # 6. Create Primary NIC
    az network nic create \
        --resource-group "$MyResourceGroup" \
        --name "$MyNIC1" \
        --vnet-name "$MyVNet" \
        --subnet "$MySubnet" \
        --network-security-group "$MyNSG" \
        --public-ip-address "$MyPublicIP" \
        --ip-forwarding true || { echo "Failed to create primary NIC"; exit 1; }


    # 7. Create Secondary NIC
    az network nic create \
        --resource-group "$MyResourceGroup" \
        --name "$MyNIC2" \
        --vnet-name "$MyVNet" \
        --subnet "$MySubnet2" \
        --network-security-group "$MyNSG" \
        --ip-forwarding true || { echo "Failed to create secondary NIC"; exit 1; }

    # 8. Create Ubuntu VM with primary NIC
    az vm create \
        --resource-group "$MyResourceGroup" \
        --name "$MyVM" \
        --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
        --size Standard_D2s_v3 \
        --admin-username azureuser \
        --generate-ssh-keys \
        --nics "$MyNIC1" \
        --custom-data cloud-init.txt || { echo "Failed to create VM"; exit 1; }

    # 9. Deallocate to add secondary NIC
    az vm deallocate \
        --resource-group "$MyResourceGroup" \
        --name "$MyVM" || { echo "Failed to deallocate VM"; exit 1; }

    # 10. Add secondary NIC
    az vm nic add \
        --resource-group "$MyResourceGroup" \
        --vm-name "$MyVM" \
        --nics "$MyNIC2" \
        --primary-nic "$MyNIC1" || { echo "Failed to add secondary NIC"; exit 1; }

    # 11. Start VM
    az vm start \
        --resource-group "$MyResourceGroup" \
        --name "$MyVM" || { echo "Failed to start VM"; exit 1; }

    # 12. Get connection information
    PUBLIC_IP=$(az network public-ip show --resource-group "$MyResourceGroup" --name "$MyPublicIP" --query ipAddress -o tsv)
    echo ""
    echo "===================================================================="
    echo "VM provisioning complete!"
    echo "SSH command: ssh azureuser@$PUBLIC_IP"
    echo "Docker will be automatically installed and ready for use"
    echo "Web access: http://$PUBLIC_IP"
    echo "===================================================================="


}

# Function to create Ubuntu client in internal network
create_ubuntu_client_in_internalnet() {
    # Note: Public IP omitted for internal client to enforce routing through main VM
    az network nic create \
        --resource-group "$MyResourceGroup" \
        --name "$MyClientNIC" \
        --vnet-name "$MyVNet" \
        --subnet "$MySubnet2" \
        --network-security-group "$MyNSG" || { echo "Failed to create client NIC"; exit 1; }

    az vm create \
        --resource-group "$MyResourceGroup" \
        --name client \
        --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
        --size Standard_D1_v2 \
        --admin-username azureuser \
        --generate-ssh-keys \
        --nics "$MyClientNIC" || { echo "Failed to create client VM"; exit 1; }
}

# Function to create Ubuntu client in external network
create_ubuntu_client_in_externalnet() {
echo omit    az network public-ip create \
        --resource-group "$MyResourceGroup" \
        --name "$MyPublicIP3" \
        --sku Standard || { echo "Failed to create external client public IP"; exit 1; }

    az network nic create \
        --resource-group "$MyResourceGroup" \
        --name "$MyExternalClientNIC" \
        --vnet-name "$MyVNet" \
        --subnet "$MySubnet" \
        --network-security-group "$MyNSG" 
#        --public-ip-address "$MyPublicIP3" || { echo "Failed to create external client NIC"; exit 1; }

    az vm create \
        --resource-group "$MyResourceGroup" \
        --name external-client \
        --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
        --size Standard_D1_v2 \
        --admin-username azureuser \
        --generate-ssh-keys \
        --nics "$MyExternalClientNIC" || { echo "Failed to create external client VM"; exit 1; }
}

# Function to create UDR to route traffic via main VM
create_udr_to_fortigate() {

    INTERNAL_NIC_IP=$(az network nic show --resource-group "$MyResourceGroup" --name "$MyNIC2" --query 'ipConfigurations[0].privateIPAddress' -o tsv)
        
    echo "Internal NIC IP for UDR: $INTERNAL_NIC_IP"

    az network route-table create \
        --name "$MyRouteTable" \
        --resource-group "$MyResourceGroup" \
        --location "$LOCATION" || { echo "Failed to create route table"; exit 1; }

    az network route-table route create \
        --name "$MyRoute" \
        --resource-group "$MyResourceGroup" \
        --route-table-name "$MyRouteTable" \
        --address-prefix "$MyRouteEntry" \
        --next-hop-type VirtualAppliance \
        --next-hop-ip-address "$INTERNAL_NIC_IP" || { echo "Failed to create route"; exit 1; }


EXTERNAL_SUBNET_ROUTE="to_external_subnet"
az network route-table route create \
    --name "$EXTERNAL_SUBNET_ROUTE" \
    --resource-group "$MyResourceGroup" \
    --route-table-name "$MyRouteTable" \
    --address-prefix "10.0.1.0/24" \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address "$INTERNAL_NIC_IP" || { echo "Failed to create route for 10.0.1.0/24"; exit 1; }
 

    az network vnet subnet update \
        --name "$MySubnet2" \
        --resource-group "$MyResourceGroup" \
        --vnet-name "$MyVNet" \
        --route-table "$MyRouteTable" || { echo "Failed to update subnet with route table"; exit 1; }
}

function createudrforexternalnet() {
EXTERNAL_NIC_IP=$(az network nic show --resource-group "$MyResourceGroup" --name "$MyNIC1" --query 'ipConfigurations[0].privateIPAddress' -o tsv)
    echo "External NIC IP: $EXTERNAL_NIC_IP"

    # Create route table for externalSubnet
    az network route-table create \
        --name "externalRouteTable" \
        --resource-group "$MyResourceGroup" \
        --location "$LOCATION" || { echo "Failed to create external route table"; exit 1; }

    # Add route for externalSubnet
    az network route-table route create \
        --name "to_internal" \
        --resource-group "$MyResourceGroup" \
        --route-table-name "externalRouteTable" \
        --address-prefix "10.0.2.0/24" \
        --next-hop-type VirtualAppliance \
        --next-hop-ip-address "$EXTERNAL_NIC_IP" || { echo "Failed to create route for 10.0.2.0/24"; exit 1; }

    # Associate with externalSubnet
    az network vnet subnet update \
        --name "$MySubnet" \
        --resource-group "$MyResourceGroup" \
        --vnet-name "$MyVNet" \
        --route-table "externalRouteTable" || { echo "Failed to update external subnet"; exit 1; }
}

function test_host_reachability() {
set -x
echo "Testing connectivity from internal client to external client..."
PUBLIC_IP=$(az network public-ip show --resource-group "$MyResourceGroup" --name "$MyPublicIP" --query ipAddress -o tsv)
echo $PUBLIC_IP
INTERNAL_CLIENT_IP=$(az network nic show --resource-group "$MyResourceGroup" --name "$MyClientNIC" --query 'ipConfigurations[0].privateIPAddress' -o tsv)
EXTERNAL_CLIENT_IP=$(az network nic show --resource-group "$MyResourceGroup" --name "$MyExternalClientNIC" --query 'ipConfigurations[0].privateIPAddress' -o tsv)
ssh -o StrictHostKeyChecking=no azureuser@$INTERNAL_CLIENT_IP -J azureuser@$PUBLIC_IP  "ping -I eth0 -c 4 $EXTERNAL_CLIENT_IP"
ssh -o StrictHostKeyChecking=no azureuser@$EXTERNAL_CLIENT_IP -J azureuser@$PUBLIC_IP  'tmux new-session -d -s httpserver "python3 -m http.server"'
ssh -o StrictHostKeyChecking=no azureuser@$INTERNAL_CLIENT_IP -J azureuser@$PUBLIC_IP  "curl -v -m 5 -H 'User-Agent: () { :; }; /bin/ls' http://$EXTERNAL_CLIENT_IP:8000"
#ssh -o StrictHostKeyChecking=no azureuser@$PUBLIC_IP docker exec -it $MycFOSContainerName tail /var/log/log/ips.0
}

function show_cfos_log() {
set -x
echo "Testing connectivity from internal client to external client..."
PUBLIC_IP=$(az network public-ip show --resource-group "$MyResourceGroup" --name "$MyPublicIP" --query ipAddress -o tsv)
echo $PUBLIC_IP
ssh -t  -o StrictHostKeyChecking=no azureuser@$PUBLIC_IP docker exec -it $MycFOSContainerName tail /var/log/log/traffic.0
ssh -t  -o StrictHostKeyChecking=no azureuser@$PUBLIC_IP docker exec -it $MycFOSContainerName tail /var/log/log/ips.0
}


function create_cfos() {
    local imagetag="${1:-interbeing/fos:x86v255}"
    local repo_type="${2:-private}"
    local container_name="${3:-$MycFOSContainerName}"
    MycFOSContainerName=$container_name

    PUBLIC_IP=$(az network public-ip show --resource-group "$MyResourceGroup" --name "$MyPublicIP" --query ipAddress -o tsv)

    # Check Docker authentication if repo is private
    if [ "$repo_type" = "private" ]; then
        if ! ssh azureuser@$PUBLIC_IP "grep -q 'https://index.docker.io/v1/' ~/.docker/config.json 2>/dev/null"; then
            echo "Docker authentication required for private repository..."
            ssh -t azureuser@$PUBLIC_IP "docker login"
        fi
    fi

    # Check if image exists before pulling
    ssh azureuser@$PUBLIC_IP \
        "if ! docker inspect --type=image $imagetag >/dev/null 2>&1; then
            echo 'Pulling Docker image...'
            docker pull $imagetag
        else
            echo 'Image $imagetag already exists. Skipping pull.'
        fi"

    # Run container
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null azureuser@$PUBLIC_IP \
        "docker run -it -d --name $container_name --network host --privileged -v cfosdata:/data $imagetag"

    # Verify container status
    echo -e "\nContainer status:"
    ssh azureuser@$PUBLIC_IP "docker ps --filter 'name=$container_name'"

    # Display credentials
    echo -e "\nLogin credentials:"
    echo "Username: admin"
    echo "Password: [empty]"

    if ! ssh -t azureuser@$PUBLIC_IP "docker exec -i cfos ls /etc/device.crt" ; then 
       echo "Use 'execute import-license' to import license after login if license not yet applied"
       ssh -t azureuser@$PUBLIC_IP "docker exec -it $container_name /bin/cli"
    else
       echo license already exist
    fi 
}

function config_cfos_policy() {
set -x 
    filename="policy.json"

    # Create policy.json locally
    cat << EOF > "$filename"
[
    {
        "policyid": 10,
        "status": "enable",
        "utm-status": "enable",
        "name": "",
        "comments": "",
        "srcintf": [
            "eth1"
        ],
        "dstintf": [
            "eth0"
        ],
        "srcaddr": [
            "all"
        ],
        "dstaddr": [
            "all"
        ],
        "srcaddr6": [],
        "dstaddr6": [],
        "service": [
            "ALL"
        ],
        "ssl-ssh-profile": "no-inspection",
        "profile-type": "single",
        "profile-group": "",
        "profile-protocol-options": "default",
        "av-profile": "",
        "webfilter-profile": "",
        "ips-sensor": "default",
        "application-list": "",
        "action": "accept",
        "nat": "disable",
        "custom-log-fields": [],
        "logtraffic": "all"
    }
]
EOF

    # Get public IP
    PUBLIC_IP=$(az network public-ip show --resource-group "$MyResourceGroup" --name "$MyPublicIP" --query ipAddress -o tsv)

echo $PUBLIC_IP
    # Copy policy.json to the VM
    scp -o StrictHostKeyChecking=no "$filename" azureuser@$PUBLIC_IP:~/policy.json

    # Copy file from VM into the cfos container
    ssh -t azureuser@$PUBLIC_IP "docker exec -i $MycFOSContainerName sh -c '/bin/busybox more > /data/cmdb/config/firewall/policy.json'" < policy.json
    ssh -t azureuser@$PUBLIC_IP "docker stop $MycFOSContainerName" 
    ssh -t azureuser@$PUBLIC_IP "docker ps"
    ssh -t azureuser@$PUBLIC_IP "docker start $MycFOSContainerName" 
    ssh -t azureuser@$PUBLIC_IP "docker ps"


}

function showcfosusage() {
echo ssh azureuser@$PUBLIC_IP docker login 
echo ssh azureuser@$PUBLIC_IP docker pull interbeing/fos:x86v255

echo step 1. run cfos on $PUBLIC_IP and apply license
echo docker run -it -d --rm --name cfos --network host --privileged -v cfosdata:/data interbeing/fos:x86v255
echo docker exec -it cfos sh
echo config cfos with policy 
echo config firewall policy
echo    edit 10
echo        set utm-status enable
echo        set srcintf "eth1"
echo        set dstintf "eth0"
echo        set srcaddr "all"
echo        set dstaddr "all"
echo        set service "ALL"
echo        set ips-sensor "default"
echo        set logtraffic all
echo    next
echo end
echo step 2. run web server on $EXTERNAL_CLIENT_IP with python3 -m http.server in tmux 
echo step 3. run attak on $INTERNAL_CLIENT_IP 
echo curl -v  -m 5 -H "User-Agent: () { :; }; /bin/ls" http://$EXTERNAL_CLIENT_IP:8000
echo "check log on cfos with tail -f /var/log/log/ips.0"
echo "docker exec -it cfos tail /var/log/log/ips.0
date=2025-05-11 time=23:55:50 eventtime=1747007750 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.0.2.5 dstip=10.0.1.5 srcintf="eth1" dstintf="eth0" sessionid=5 action="dropped" proto=6 service="HTTP" policyid=10 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=57658 dstport=8000 hostname="10.0.1.5" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=246415361 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution"
date=2025-05-11 time=23:57:26 eventtime=1747007846 tz="+0000" logid="0419016384" type="utm" subtype="ips" eventtype="signature" level="alert" severity="critical" srcip=10.0.2.5 dstip=10.0.1.5 srcintf="eth1" dstintf="eth0" sessionid=6 action="dropped" proto=6 service="HTTP" policyid=10 attack="Bash.Function.Definitions.Remote.Code.Execution" srcport=46990 dstport=8000 hostname="10.0.1.5" url="/" direction="outgoing" attackid=39294 profile="default" incidentserialno=246415362 msg="applications3: Bash.Function.Definitions.Remote.Code.Execution""

}

function print_usage() {
echo "Usage: $0 {imagetag [public | private ] region "
echo "Example ./$0 interbeing/fos:x86v255 private westus2"
echo "Example ./$0 yourrepo  public westus2"
}

function main() {
if [ $# -lt 1 ]; then
    print_usage
    exit 1
fi 

local image="${1:-interbeing/fos:x86v255}"
local mode="${2:-private}"
local location="${3:-westus2}"
provision_azure_resources 
create_ubuntu_client_in_internalnet
create_ubuntu_client_in_externalnet
create_udr_to_fortigate
createudrforexternalnet
create_cfos $image $mode "cfos" 
config_cfos_policy 
test_host_reachability
show_cfos_log
}

main $@
