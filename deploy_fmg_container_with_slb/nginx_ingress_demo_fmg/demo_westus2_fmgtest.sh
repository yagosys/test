#!/bin/bash -xe
[[ -z $1 ]] && location="westus2" || location=$1
[[ -z $2 ]] && fmgdnslabel="fmgtest" || fmgdnslabel=$1 
./01_demo_fmg_container_enable_port80_disable_redirect.sh && \
./02_update_fmg_dns.sh $location $fmgdnslabel  && \
./03_install_cert_mgmt_create_certification_in_namespace.sh $location $fmgdnslabel && \
./04_create_internal_lb_for_fmg_443_80.sh &&  \
./05.sh && \
./06_nginx_ingress_secondary_service.sh $fmgdnslabel && \
./07_fazingress_external_secondary.sh $location $fmgdnslabel && \
kubectl create -f 08_networkpolicy_fmg.yaml
