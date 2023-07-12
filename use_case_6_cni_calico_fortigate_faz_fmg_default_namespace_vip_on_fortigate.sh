#!/bin/bash -e
if [ -z "$answer" ]; then
  answer="yes"
fi
if [[ "$answer" == 'yes' ]]; then
    echo "You chose to continue. The script will proceed..."
    # Add your additional script code here
       currentdir=$(pwd)
       cd windows
       ./create_aks_and_ubuntu_win_node_westus2_nocni.sh westus2 standard_b8ms
       cd $currentdir
       cd windows/tigera/cni
       ./install_calico_cni.sh
       cd $currentdir
       cd deploy_faz_container_with_slb
       ./use_case_0_clean_boot_faz.sh
       cd $currentdir
       cd deploy_fmg_container_with_slb
       ./use_case_0_clean_boot_fmg.sh
       cd $currentdir
       cd windows/fortigate
       ./create_fortigate_vm_with_subnet.sh
       ./create_firewall_policy_vip_for_faz_internal_slb.sh
       ./verify.sh
       cd $currentdir

else
    echo "You chose not to continue. The script will exit."
    exit 1
fi
