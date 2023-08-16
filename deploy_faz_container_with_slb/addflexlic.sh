#/bin/bash -xe
echo 'usage ./addflexlic.sh <NAMESPACE> <TOKEN>'
[[ -z $1 ]] && namespace="default" || namespace=$1
podname=$(kubectl get pod -l app=fortianalyzer -n $namespace | grep Running | awk '{ print $1 }')
echo $podname
[[ -z $2 ]] && echo please provide token || token=$2
echo $token
kubectl exec -it $podname -n $namespace -- /bin/bash -c 'echo -e "execute vm-license '"$token"'" | cli'
