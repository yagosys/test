#!/bin/bash

kubectl delete namespace fortinet
kubectl delete namespace fortimanager
kubectl create namespace fortinet
kubectl create namespace fortimanager

echo $(pwd)

cd deploy_faz_container_with_slb
./use_case_8_apply_license_and_enable_api_with_namespace.sh > faz_log.txt 2>&1 &
cd ./../

cd ./deploy_fmg_container_with_slb 
./use_case_8_apply_license_and_enable_api_with_namespace.sh > fmg_log.txt 2>&1 &

wait

cd ./../
cat ./deploy_fmg_container_with_slb/fmg_log.txt
cat ./deploy_faz_container_with_slb/faz_log.txt
echo "done"

