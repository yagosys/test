#!/bin/bash -x

function test_init() {

count=1
while [ $count -le 5 ]; do
fazpod=$(kubectl get pod -l app=fortianalyzer -n $faznamespace | grep Running | awk '{print $1}')
fmgpod=$(kubectl get pod -l app=fortimanager -n $fmgnamespace  | grep Running | awk '{print $1}')

echo $fazpod
echo $fmgpod

kubectl exec -it po/$fazpod -n $faznamespace -- pstree -p | grep init
faz_zombie_counter=0

for i in {1..3}; do
    if kubectl exec -it po/$fazpod -n $faznamespace -- ps | grep init | grep 'Z'; then
        faz_zombie_counter=$((faz_zombie_counter + 1))
        echo "found Z once in $fazpod at $faznamespace" | tee >> result.log
        echo $(kubectl exec -it po/$fazpod -n $fmgnamespace -- pstree -p | grep init) | tee >> result.log
    else
        # Reset the counter if no zombie is detected in one of the iterations
        faz_zombie_counter=0
    fi

    # Exit the loop early if no zombie is detected
    if [ $faz_zombie_counter -eq 0 ]; then
        break
    fi

    # Wait for 1 second before checking again
    if [ $i -lt 3 ]; then
        sleep 1
    fi
done 

if [ $faz_zombie_counter -eq 3 ]; then
#if kubectl exec -it po/$fazpod -n $faznamespace -- ps | grep init | grep 'Z'; then
         echo "Zombie init process detected in $fazpod!" | tee >> result.log
         echo $(date) >> result.log
         echo $(kubectl get svc fazcontainerhttps -n $faznamespace) failed | tee >> result.log
         echo with $(kubectl get svc fmgcontainerhttps -n $fmgnamespace)  | tee >> result.log
         break
fi


kubectl exec -it po/$fmgpod -n $fmgnamespace -- pstree -p | grep init

fmg_zombie_counter=0

for i in {1..3}; do
    if kubectl exec -it po/$fmgpod -n $fmgnamespace -- ps | grep init | grep 'Z'; then
        fmg_zombie_counter=$((fmg_zombie_counter + 1))
        echo "found Z once in $fmgpod at $faznamespace" | tee >> result.log
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
#if kubectl exec -it po/$fmgpod -n $fmgnamespace -- ps | grep init | grep 'Z'; then
         echo "Zombie init process detected in $fmgpod!" | tee >> result.log
         echo $(date) >> result.log
         echo $(kubectl get svc fmgcontainerhttps -n $fmgnamespace ) failed | tee >> result.log
         echo with $(kubectl get svc fazcontainerhttps -n $faznamespace )  | tee >> result.log
         break
fi

sleep 30
count=$((count + 1))
done

}

function create_faz_fmg () {
kubectl create -f pvc_faz.yaml -n $faznamespace 
kubectl create -f pvc_fmg.yaml -n $fmgnamespace 
kubectl create -f fazcontainer.yaml -n $faznamespace
kubectl create -f fmgcontainer.yaml -n $fmgnamespace
kubectl create -f fazcluster.yaml -n $faznamespace
kubectl create -f fmgcluster.yaml -n $fmgnamespace 
}

function delete_faz_fmg () {
kubectl delete -f fazcluster.yaml -n $faznamespace 
kubectl delete -f fmgcluster.yaml -n $fmgnamespace
kubectl delete -f fazcontainer.yaml -n $faznamespace 
kubectl delete -f fmgcontainer.yaml -n $fmgnamespace 
kubectl delete -f pvc_faz.yaml -n $faznamespace 
kubectl delete -f pvc_fmg.yaml -n $fmgnamespace 
}

#faznamespace="fortianalyzer"
faznamespace="fortinet"
#fmgnamespace="fortimanager"
fmgnamespace="fortinet"

kubectl create namespace $faznamespace
kubectl create namespace $fmgnamespace 
ncount=1
while [ $ncount -le 1000 ]; do
create_faz_fmg
test_init
echo completed  $ncount round | tee >> result.log
echo $(kubectl get pod -n $faznamespace) | tee >> result.log
echo $(kubectl get pod -n $fmgnamespace) | tee >> result.log
delete_faz_fmg
ncount=$((ncount+1))
done


