#!/bin/bash -x

applabel="fortianalyzer"

function wait_for_faz_ready() {
service_name="fazcontainerhttps"
while true; do
    ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$ip" || "$ip" == "<pending>" ]]; then
        echo "Waiting for IP..."
        sleep 10
    else
        echo "Public IP assigned: $ip"
        break
    fi
done

while true; do
  if nc -zv $ip 443 -w 60; then
    echo "Ping successful, breaking loop"
    curl -k -I https://$ip
    break
  fi
  sleep 2
  kubectl get pod  -l app=$applabel
done
}

wait_for_faz_ready
current_date=$(date '+%Y-%m-%d')
filename="usecase_4_${current_date}.txt"
podname=$(kubectl get pod -l app=$applabel | grep Running | awk '{ print $1 }')


echo "start use kubectl scale deployment $applabel-deployment --replicas=2 to scale out"  | tee -a $filename
kubectl scale deployment $applabel-deployment --replicas=2 | tee -a $filename
podname=$(kubectl get pod -l app=$applabel | grep 0/1 | awk '{ print $1 }')
while true; do
  if kubectl get pod $podname | grep -q "1/1"; then
    wait_for_faz_ready
    echo "scale out completed"
    break
  fi
  sleep 5
done



function get_lb_ip() {
service_name="fazcontainerhttps"
while true; do
    ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$ip" || "$ip" == "<pending>" ]]; then
        echo "Waiting for IP..."
        sleep 10
    else
        echo "Public IP assigned: $ip"
        break
    fi
done
}

function ping_lb_publicip(){
while true; do
#  if httping -qc1 "https://$ip"; then
  if nc -zv $ip 443 -w 60; then
    echo "Ping successful, breaking loop"
    curl -k -I https://$ip
    break
  fi
  sleep 2
  kubectl get pod  -l app=$applabel
done
}


get_lb_ip
ping_lb_publicip | tee -a $filename 
kubectl get ep  | tee -a $filename
kubectl get pod -l app=$applabel | tee -a $filename


