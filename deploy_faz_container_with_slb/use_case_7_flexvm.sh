#!/bin/bash -x
namespace="fortinet"
[[ -z $1 ]] || token=$1
echo $token
service_name="fazlb443"
function add_license_from_homedirectory_and_setup_admin_password() {
adminpassword="Welcome.123"
podname=$(kubectl get -n $namespace pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
echo $podname
kubectl -n $namespace exec -it $podname -- /bin/bash -c 'echo -e "config system admin user \n edit admin\n set password '$adminpassword'\n end\n" | cli'
echo cp license to container
echo $token
kubectl exec -it $podname -n $namespace -- /bin/bash -c 'echo -e "execute vm-license '"$token"'" | cli'
sleep 10
}
function reboot() {
podname=$(kubectl get -n $namespace pod -l app=fortianalyzer | grep Running | awk '{ print $1 }')
kubectl exec -it $podname -n $namespace -- /bin/bash -c 'reboot'
sleep 10
}

function wait_for_faz_ready() {
while true; do
    ip=$(kubectl get -n $namespace svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$ip" || "$ip" == "<pending>" ]]; then
        echo "Waiting for IP..."
        sleep 10
    else
        echo "Public IP assigned: $ip"
        break
    fi
done

while true; do
    # Get the pod name of the 'Running' fortianalyzer
    podname=$(kubectl get -n $namespace pod -l app=fortianalyzer -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')

    # If podname is empty, wait for a while and continue
    if [[ -z "$podname" ]]; then
        echo "Waiting for fortianalyzer pod to be in Running state..."
        sleep 2
        continue
    fi

    # Execute the curl command inside the pod
    if kubectl exec -it po/$podname -n $namespace -- curl -k -I https://$ip; then
        echo "Curl command successful, exiting loop."
        break
    fi

    # If curl is unsuccessful, sleep for a while before retrying
    sleep 2
done


}
kubectl create -f ./pvcwithnamespace.yaml 
kubectl create -f ./fazcontainerwithnamespace.yaml
cd nginx_ingress_demo_faz
./04_create_internal_lb_for_faz_443_80.sh $namespace

wait_for_faz_ready
add_license_from_homedirectory_and_setup_admin_password
wait_for_faz_ready
#reboot
#wait_for_faz_ready
