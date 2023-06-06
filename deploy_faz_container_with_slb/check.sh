#!/bin/bash -x
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


dateStart=$(date)
while true; do
#  if httping -qc1 "https://$ip"; then
  if nc -zv $ip 443; then
    echo "Ping successful, breaking loop"
    curl -k -I https://$ip
    break
  fi
  sleep 2
  kubectl get pod  -l app=fortianalyzer
done
dateStop=$(date)
current_date=$(date '+%Y-%m-%d')
filename="faz_boot_time_${current_date}.txt"
echo faz bootup record > $filename 
echo boot at $dateStart >> $filename
echo service ready at $dateStop  >> $filename
