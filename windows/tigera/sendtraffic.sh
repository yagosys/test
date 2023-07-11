kubectl exec -it po/nginx-76d6c9b8c-7tnvp -- sh -c 'for i in {1..10}; do curl -I https://1.1.1.1; sleep 2; done'
ssh azureuser@fgtvmtest1.westus2.cloudapp.azure.com  diag sys session list  | grep 1.1.1.1
