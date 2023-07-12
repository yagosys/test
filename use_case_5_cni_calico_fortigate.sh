#!/bin/bash -e
if [ -z "$answer" ]; then
  answer="yes"
fi
if [[ "$answer" == 'yes' ]]; then
    echo "You chose to continue. The script will proceed..."
    # Add your additional script code here
       currentdir=$(pwd)
       cd windows
       ./create_aks_and_ubuntu_win_node_westus2_nocni.sh
       cd fortigate
        ./create_fortigate_vm_with_subnet.sh
        cd ./../
        cd tigera/cni
       ./install_calico_cni.sh
       cd $currentdir
else
    echo "You chose not to continue. The script will exit."
    exit 1
fi
