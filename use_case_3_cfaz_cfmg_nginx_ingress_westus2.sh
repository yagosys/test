#!/bin/bash


currentdir=$(pwd)

cd deploy_faz_container_with_slb/nginx_ingress_demo_faz

./demo_westus2_faztest.sh 

cd $currentdir

cd deploy_fmg_container_with_slb/nginx_ingress_demo_fmg
./demo_westus2_fmgtest.sh 

cd $currentdir






