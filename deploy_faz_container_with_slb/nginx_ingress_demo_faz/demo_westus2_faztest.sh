#!/bin/bash -x
[[ -z $1 ]] && location="westus2" || location=$1
[[ -z $2 ]] && fazdnslabel="faztest" || fazdnslabel=$2
echo $fazdnslabel
echo $location
./01_step1-demo_faz_container_enable_port80_disable_redirect.sh && \
./02_update_faz_dns.sh $location $fazdnslabel  && \
./03_install_cert_mgmt_create_certification_in_namespace.sh $location $fazdnslabel && \
./04_create_internal_lb_for_faz_443_80.sh &&  \
./05.sh && \
./06_nginx_ingress_controller_aks_lb_service.sh $fazdnslabel && \
./07_fazingress_external.sh $location $fazdnslabel && \
kubectl create -f 08_networkpolicy_faz.yaml
