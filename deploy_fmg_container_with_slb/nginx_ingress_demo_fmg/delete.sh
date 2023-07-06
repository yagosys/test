kubectl delete -f 05_standard_ingress_deploy_without_lbsvc.yaml 
kubectl delete -f nginx-ingress-secondary-controller.yaml
kubectl delete namespace fortimanager 
kubectl delete namespace ingress-nginx 
kubectl delete namespace cert-manager
az network  public-ip delete  -g wandyaks -n fmgpublicip
