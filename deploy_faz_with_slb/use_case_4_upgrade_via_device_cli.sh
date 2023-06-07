#!/bin/bash -xe 
echo 'usage  use_case_4_upgrade_via_device_cli.sh <ip> <username> <password>'
if [ -z "$1" ]; then echo "Need IP."; exit 1; fi
if [ -z "$2" ]; then echo "Need Username."; exit 1; fi
if [ -z "$3" ]; then echo "Need Password."; exit 1; fi

ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Assuming "execute restore image" is a command
ssh admin@$ip "execute restore image scp /root/FAZ_VM64_IBM-v7.2.2-build1334-FORTINET.out \"$1\" \"$2\" \"$3\""


