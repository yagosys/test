#!/bin/bash -x
service_name="fmgcontainerhttps"


echo fmg bootup record > result.txt
echo boot at $dateStart >> result.txt

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
  if httping -qc1 "https://$ip"; then
    echo "Ping successful, breaking loop"
    curl -k -I https://$ip
    break
  fi
  sleep 2
  kubectl get pod  -l app=fortimanager
done
dateStop=$(date)

echo service ready at $dateStop  >> result.txt
