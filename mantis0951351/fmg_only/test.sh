#!/bin/bash -x

function test_init() {

echo ------CHECK FOR ZOMBIE PROCESS ---------- | tee >> result.log
count=1
while [ $count -le 5 ]; do
fmgpod=$(kubectl get pod -l app=fortimanager -n $fmgnamespace | grep Running | awk '{print $1}')

echo $fmgpod

kubectl exec -it po/$fmgpod -n $fmgnamespace -- pstree -p | grep init
fmg_zombie_counter=0

for i in {1..3}; do
    if kubectl exec -it po/$fmgpod -n $fmgnamespace -- ps | grep init | grep 'Z'; then
        fmg_zombie_counter=$((fmg_zombie_counter + 1))
        echo "found Z once in $fmgpod at $fmgnamespace" | tee >> result.log
        echo $(kubectl exec -it po/$fmgpod -n $fmgnamespace -- pstree -p | grep init) | tee >> result.log
    else
        # Reset the counter if no zombie is detected in one of the iterations
        fmg_zombie_counter=0
    fi

    # Exit the loop early if no zombie is detected
    if [ $fmg_zombie_counter -eq 0 ]; then
        break
    fi

    # Wait for 1 second before checking again
    if [ $i -lt 3 ]; then
        sleep 1
    fi
done 

if [ $fmg_zombie_counter -eq 3 ]; then
         echo "Zombie init process detected in $fmgpod!" | tee >> result.log
         echo $(date) >> result.log
         echo $(kubectl get svc fmgcontainerhttps -n $fmgnamespace) failed | tee >> result.log
         exit
fi


echo sleep 30
sleep 30
count=$((count + 1))
done

}

function create_fmg_fmg () {
echo ------CREATE DEPLOYMENT ------ | tee >> result.log
kubectl delete namespace $fmgnamespace
kubectl create namespace $fmgnamespace
kubectl create -f pvc_fmg.yaml -n $fmgnamespace 
sleep 2
kubectl create -f fmgcontainer.yaml -n $fmgnamespace
#sleep 2
kubectl create -f fmgcluster.yaml -n $fmgnamespace 
sleep 30
kubectl create -f ingress.yaml -n $fmgnamespace
}

function delete_fmg_fmg () {
echo ------DELETE DEPLOYMENT ----- | tee >> result.log
kubectl delete -f fmgcluster.yaml -n $fmgnamespace 
kubectl delete -f fmgcontainer.yaml -n $fmgnamespace 
kubectl delete -f pvc_fmg.yaml -n $fmgnamespace 
}

fmgnamespace="fortinet"

kubectl create namespace $fmgnamespace
ncount=1
while [ $ncount -le 1000 ]; do
create_fmg_fmg
test_init
echo completed  $ncount round | tee >> result.log
echo $(kubectl get pod -n $fmgnamespace) | tee >> result.log
delete_fmg_fmg
ncount=$((ncount+1))
done


