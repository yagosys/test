#!/bin/bash -e
echo before continue, please go to calicocloud.io to get license and update file
echo windows/tigera/00_please_update_before_run_register_to_calicocloud.sh
echo if no input given, the script will continue after 60 secons
sleep 10 
if ! read -t 60 -p "Do you wish to continue? [yes/no]: " answer; then
  answer="yes"
fi
# If no input was given, default to "yes"
if [ -z "$answer" ]; then
  answer="yes"
fi
if [[ "$answer" == 'yes' ]]; then
    echo "You chose to continue. The script will proceed..."
    # Add your additional script code here
       currentdir=$(pwd)
       cd windows
       ./create_aks_and_ubuntu_win_node_westus2_azure_cni.sh
       cd fortigate
        ./create_fortigate_vm_with_subnet.sh
        cd ./../
        cd tigera
       ./demo.sh
else
    echo "You chose not to continue. The script will exit."
    exit 1
fi
