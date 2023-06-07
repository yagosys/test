kubectl delete -f faz707temp.yaml && kubectl delete pvc faz && kubectl delete pvc cidata && kubectl create -f cidatadv.yaml  && kubectl create -f fazdv.yaml && kubectl create -f faz707temp.yaml
