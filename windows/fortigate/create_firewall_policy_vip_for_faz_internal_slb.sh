#!/bin/bash -xe
filename="slbfirewallpolicy"
extip=$(ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com get system interface physical port1  | grep ip: | awk '{print $2}')
echo $extip
fazslbip=$(kubectl get svc fazlb443 -o json | jq -r .status.loadBalancer.ingress[].ip )
fmgslbip=$(kubectl get svc fmglb443 -o json | jq -r .status.loadBalancer.ingress[].ip )
echo $fazslbip
echo $fmgslbip
cat << EOF >$filename
config firewall vip
    edit "fazslb"
        set extip $extip
        set mappedip $fazslbip
        set extintf "any"
        set portforward enable
        set extport 18443
        set mappedport 443
    next
end
config firewall vip
    edit "fmgslb"
        set extip $extip
        set mappedip $fmgslbip
        set extintf "any"
        set portforward enable
        set extport 19443
        set mappedport 443
    next
end
config firewall policy
    edit 3
        set name "ingresstofazslb"
        set srcintf "port1"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "fazslb"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
    edit 4
        set name "ingresstofmgslb"
        set srcintf "port1"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "fmgslb"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
move 3 before 1
move 4 before 1
end
EOF
ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com <$filename
ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com show firewall policy
