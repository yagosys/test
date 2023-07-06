kubectl create secret generic fortigate \
-n tigera-firewall-controller \
--from-literal=fortigate-key="abcdefghijklmn"
