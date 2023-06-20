#!/bin/bash


currentdir=$(pwd)

cd deploy_faz_container_with_slb/nginx_ingress_demo_faz

./demo.sh &

cd $currentdir

cd deploy_fmg_container_with_slb/nginx_ingress_demo_fmg
./demo.sh &

cd $currentdir

wait 





