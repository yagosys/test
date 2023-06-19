#!/bin/bash


currentdir=$(pwd)

cd deploy_faz_container_with_slb/faz_kong_ingress_with_domainname_demo

./step1-demo_faz_container_enable_port80_disable_redirect.sh && \
./step2_create_kong_with_static_ip.sh  && \
./step3_install_cert_mgmt.sh && \
./step4_deploy_ingressrule_for_fortianalyzer.sh   &

cd $currentdir

cd deploy_fmg_container_with_slb/fmg_kong_ingress_with_domainname_demo

./step1-demo_fmg_container_enable_port80_disable_redirect.sh && \
./step2_create_kong_with_static_ip.sh  && \
./step3_install_cert_mgmt.sh && \
./step4_deploy_ingressrule_for_fortimanager.sh  &

wait 





