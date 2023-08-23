#!/bin/bash -x
echo "usage: ./use_case_7.sh <faz_flexvmlicense> <fmg_flexvmlicense> "
sleep 5
instanceType="standard_f16s_v2"
namespace="fortinet"
#instanceType="standard_b8ms"
if [ -z "$answer" ]; then
  answer="yes"
fi
if [[ "$answer" == 'yes' ]]; then
    echo "You chose to continue. The script will proceed..."
    # Add your additional script code here
       currentdir=$(pwd)
       cd windows
       #./create_aks_and_ubuntu_win_node_westus2_nocni.sh westus2  $instanceType
       ./create_aks_and_ubuntu_win_node_westus2_nocni.sh eastasia  $instanceType
       cd $currentdir
       cd windows/tigera/cni
       ./install_calico_cni.sh
       kubectl create namespace $namespace
       cd $currentdir
       cd deploy_faz_container_with_slb
       ./use_case_7_flexvm.sh $1 & 
       cd $currentdir
       cd deploy_fmg_container_with_slb
       ./use_case_7_flexvm.sh $2 &
       cd $currentdir
       wait 
       cd windows/fortigate
       ./create_fortigate_vm_with_subnet.sh eastasia
       ./create_firewall_policy_vip_for_faz_internal_slb.sh eastasia $namespace
       ./verify.sh eastasia
       cd $currentdir
       sleep 50
       ./config_fmg_to_faz.sh

else
    echo "You chose not to continue. The script will exit."
    exit 1
fi
