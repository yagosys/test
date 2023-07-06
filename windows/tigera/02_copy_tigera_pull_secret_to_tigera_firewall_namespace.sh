kubectl get secret tigera-pull-secret --namespace=calico-system -o yaml | \
grep -v '^[[:space:]]*namespace:[[:space:]]*calico-system' | \
kubectl apply --namespace=tigera-firewall-controller -f -
