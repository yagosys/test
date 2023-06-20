#!/bin/bash


currentdir=$(pwd)

cd deploy_faz_container_with_slb/nginx_ingress_demo_faz

./delete.sh

cd $currentdir

cd deploy_fmg_container_with_slb/nginx_ingress_demo_fmg
./delete.sh

cd $currentdir






