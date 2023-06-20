./01_demo_fmg_container_enable_port80_disable_redirect.sh && \
./02_update_fmg_dns.sh && \
./03_install_cert_mgmt_create_certification_in_namespace.sh && \
./04_create_internal_lb_for_fmg_443_80.sh &&  \
./05.sh && \
./06_nginx_ingress_secondary_service.sh && \
#./06_nginx_ingress_controller_aks_lb_service.sh && \
./07_fazingress_external_secondary.sh
#./07_fmgingress_external.sh
