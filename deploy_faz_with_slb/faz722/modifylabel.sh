#apply license on both faz
#backup config from faz
#restorte config on faz722
#check lb endpoint ip 
kubectl get ep  fazvmhttps
kubectl get ep  fazvmhttpsforupgrade
#modify lb to selector new faz722 based on label
kubectl patch svc fazvmhttps -p '{"spec":{"selector":{"kubevirt.io/domain":"faz722"}}}'
#modify new lb to use old faz vm based on it's label
kubectl patch svc fazvmhttpsforupgrade  -p '{"spec":{"selector":{"kubevirt.io/domain":"faz"}}}'
#check lb endpoint ip change
kubectl get ep fazvmhttps
kubectl get ep fazvmhttpsforupgrade

