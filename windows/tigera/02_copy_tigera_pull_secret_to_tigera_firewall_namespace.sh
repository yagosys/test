kubectl get secret tigera-pull-secret --namespace=calico-system -o yaml | \
grep -v '^[[:space:]]*namespace:[[:space:]]*calico-system' | \
kubectl apply --namespace=tigera-firewall-controller -f -
kubectl get secret tigera-pull-secret -n tigera-firewall-controller -o yaml | grep dockerconfigjson: | cut -d ':' -f 2 | tr -d ' ' | base64 -d
