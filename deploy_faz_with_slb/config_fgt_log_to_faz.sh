#!/bin/bash 
service_name="fazvmhttps"
ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $ip
fazsn=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  $ip 'get system status' | grep "Serial Number" | cut -d ':' -f 2 | tr -d ' ')
echo $fazsn
fgtip=$1
echo $fgtip
[[ -z $fgtip ]] &&  fgtip="52.246.137.113"
echo $fazcn
cat << EOF  
config log fortianalyzer setting
    set status enable
    set server $fgtip
    set serial $fazsn
end
EOF
