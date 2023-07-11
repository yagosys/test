#!/bin/bash -xe


# Function to check if all tigerastatus resources are available
check_tigerastatus() {
  # Get the list of names
    while true; do
    names=$(kubectl get tigerastatus -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

    #  wait until tigerastatus has 9 resources which are apiserver calico cloud-core compliance image-assurance intrusion-detection log-collector management-cluster-connection monitor
    [[ $(echo $names | wc -w) == '9' ]] && break || sleep 5
  done
  

  for name in $names; do
    # Get the AVAILABLE status for each name
    status=$(kubectl get tigerastatus $name -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
    echo $name is $status
    if [ "$status" != "True" ]; then
      echo "AVAILABLE status for $name is not True."
      return 1
    fi
  done

  # If the function hasn't returned by now, all statuses are True
  echo "All Tigerastatus resources are now available."
  return 0
}

# Loop until all tigerastatus resources are available
while ! check_tigerastatus; do
  echo "Waiting for all Tigerastatus resources to be available..."
  sleep 5
done

cat << EOF | kubectl apply -f -
kind: Namespace
apiVersion: v1
metadata:
  name: tigera-firewall-controller
EOF
