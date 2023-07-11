#!/bin/bash -xe
./00_please_update_before_run_register_to_calicocloud.sh
./00-tigera-namespace.yaml.sh
./01-tigera-firewall-controller-configmap.yaml.sh
./02_copy_tigera_pull_secret_to_tigera_firewall_namespace.sh
./03_create_fortigate_api_key.sh
./04_fortinet_firewall_controller.yaml.sh
./06_create_tigera_tier_yaml.sh
./07_networkpolicyegress.yaml.sh
./08_create_new_firewall_policy_for_targetedtraffic.sh
