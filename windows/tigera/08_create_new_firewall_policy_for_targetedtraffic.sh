#!/bin/bash -xe
filename="firepolicyfortigate.production-microservice1"
cat << EOF >$filename
config firewall policy
    edit 2
        set name "aksnodetointeret"
        set srcintf "port2"
        set dstintf "port1"
        set action accept
        set srcaddr "fortigate.production-microservice1"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
next
move 2 before 1
end
EOF
ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com <$filename
ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com show firewall policy
