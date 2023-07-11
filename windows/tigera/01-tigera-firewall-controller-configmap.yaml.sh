#!/bin/bash -xe
fgtip=$(ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com get system interface | grep "name: port2" | cut -d ":" -f 4 | cut -d " " -f 2)
[[ -z $fgtip ]] && fgtip="10.224.1.26"
echo $fgtip
tier="fortigate"

# Configuration of Tigera Firewall Controller
filename=fortinet_configmap.yml
cat << EOF > $filename
kind: ConfigMap
apiVersion: v1
metadata:
  name: tigera-firewall-controller-configs
  namespace: tigera-firewall-controller
data:
  # FortiGate device information
  tigera.firewall.fortigate: |
    - name: fortigate
      ip: $fgtip   ####### UPDATE with FortiGate Private IP
      apikey:
        secretKeyRef:
          name: fortigate
          key: fortigate-key
  # This part required when using FortiManager integration
  tigera.firewall.fortimgr: |-
  #   - name: fortimgr
  #     ip: 10.99.1.X   ####### UPDATE with FortiManager Private IP
  #     username: tigera_fortimanager_admin
  #     adom: root
  #     password:
  #       secretKeyRef:
  #         name: fortimgr-ns
  #         key: fortimgr-pwd
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: tigera-firewall-controller
  namespace: tigera-firewall-controller
data:
  tigera.firewall.addressSelection: node
  tigera.firewall.policy.selector: projectcalico.org/tier == $tier
EOF

kubectl apply -f $filename
kubectl get cm -n tigera-firewall-controller

