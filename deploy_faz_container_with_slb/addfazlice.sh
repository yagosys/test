#!/bin/bash -x
licfile=$1
[[ $licfile == "" ]] && licfile="VMTM23008295.lic"
if [ ! -f "$HOME/$licfile" ]; then
    echo "File $HOME/$licfile does not exist. put a license file in $HOME"
    exit 1
fi
adminpassword="Welcome.123"
podname=$(kubectl get pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
echo $podname

echo cp license to container
kubectl cp $HOME/$licfile $podname:/tmp/$licfile
sleep 5
echo config admin password to $adminpassword
kubectl exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli'
echo add license from $licfile

kubectl exec -it $podname -- /bin/bash -c 'echo -e "execute add-vm-license \"$(cat /tmp/'$licfile')\"" | cli'
