./01_step1-demo_faz_container_enable_port80_disable_redirect.sh && \
./02_update_faz_dns.sh && \
./03_install_cert_mgmt_create_certification_in_namespace.sh && \
./04_create_internal_lb_for_faz_443_80.sh &&  \
./05.sh && \
./06_nginx_ingress_controller_aks_lb_service.sh && \
./07_fazingress_external.sh
