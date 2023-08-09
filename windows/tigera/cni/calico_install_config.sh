check_tigerastatus() {
  # Get the list of names
    while true; do
    names=$(kubectl get tigerastatus -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

    #  wait until tigerastatus has 9 resources which are apiserver calico cloud-core compliance image-assurance intrusion-detection log-collector management-cluster-connection monitor
    [[ $(echo $names | wc -w) == '2' ]] && break || sleep 5
  done

  for name in $names; do
    # Get the AVAILABLE status for each name
    status=$(kubectl get tigerastatus $name -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
    echo $name is $status
      while [[ "$status" != "True" ]] ; do 
          sleep 2
	  status=$(kubectl get tigerastatus $name -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
	  echo $name is $status
     done
     
  done

  # If the function hasn't returned by now, all statuses are True
  echo "All Tigerastatus resources are now available."
  return 0
}

kubectl create -f - <<EOF
kind: Installation
apiVersion: operator.tigera.io/v1
metadata:
  name: default
spec:
  kubernetesProvider: AKS
  cni:
    type: Calico
  calicoNetwork:
    bgp: Disabled
    ipPools:
     - cidr: 192.168.0.0/16
       encapsulation: VXLAN
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
   name: default
spec: {}
EOF
check_tigerastatus
kubectl get node -o wide
