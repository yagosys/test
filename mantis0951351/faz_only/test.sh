#!/bin/bash -x

function test_init() {

echo ------CHECK FOR ZOMBIE PROCESS ---------- | tee >> result.log
count=1
while [ $count -le 5 ]; do
fazpod=$(kubectl get pod -l app=fortianalyzer -n $faznamespace | grep Running | awk '{print $1}')

echo $fazpod

kubectl exec -it po/$fazpod -n $faznamespace -- pstree -p | grep init
faz_zombie_counter=0

for i in {1..3}; do
    if kubectl exec -it po/$fazpod -n $faznamespace -- ps | grep init | grep 'Z'; then
        faz_zombie_counter=$((faz_zombie_counter + 1))
        echo "found Z once in $fazpod at $faznamespace" | tee >> result.log
        echo $(kubectl exec -it po/$fazpod -n $faznamespace -- pstree -p | grep init) | tee >> result.log
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
         echo "Zombie init process detected in $fazpod!" | tee >> result.log
         echo $(date) >> result.log
         echo $(kubectl get svc fazcontainerhttps -n $faznamespace) failed | tee >> result.log
         exit
fi


echo sleep 30
sleep 30
count=$((count + 1))
done

}

function create_faz_fmg () {
echo ------CREATE DEPLOYMENT ------ | tee >> result.log
kubectl create -f pvc_faz.yaml -n $faznamespace 
sleep 5
kubectl create -f fazcontainer.yaml -n $faznamespace
sleep 5
kubectl create -f fazcluster.yaml -n $faznamespace 
sleep 30
}

function delete_faz_fmg () {
echo ------DELETE DEPLOYMENT ----- | tee >> result.log
kubectl delete -f fazcluster.yaml -n $faznamespace 
kubectl delete -f fazcontainer.yaml -n $faznamespace 
kubectl delete -f pvc_faz.yaml -n $faznamespace 
}

faznamespace="fortinet"

kubectl create namespace $faznamespace
ncount=1
while [ $ncount -le 1000 ]; do
create_faz_fmg
test_init
echo completed  $ncount round | tee >> result.log
echo $(kubectl get pod -n $faznamespace) | tee >> result.log
delete_faz_fmg
ncount=$((ncount+1))
done


