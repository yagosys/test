#!/bin/bash 
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
echo $podname
fazsn=$(kubectl exec -it $podname -- /bin/bash -c 'echo -e "get system status" | cli'  | grep "Serial Number" | cut -d ':' -f 2 | tr -d ' ')
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
