#!/bin/bash -xe 
echo 'usage  use_case_4_upgrade_via_device_cli.sh <ip> <username> <password>'
if [ -z "$1" ]; then echo "Need IP."; exit 1; fi
if [ -z "$2" ]; then echo "Need Username."; exit 1; fi
if [ -z "$3" ]; then echo "Need Password."; exit 1; fi
service_name="fazvmhttps"
image_name="/root/FAZ_VM64_IBM-v7.2.2-build1334-FORTINET.out"
echo $image_name

ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
# Assuming "execute restore image" is a command
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  admin@$ip "execute restore image scp $image_name \"$1\" \"$2\" \"$3\""


