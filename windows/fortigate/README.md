##diagram
```bash
10.0.2.5 ----10.0.2.4--eth1-(cFOS on ubuntu vM)-eth0 ---10.0.1.4 ---10.0.1.5
```

## ubuntu vm config

### 1. run cfos with host network
```bash
docker run -it -d --name $container_name --network host --privileged -v cfosdata:/data $imagetag

```

### 2. iptable rule
allow traffic from eth1 to eth0 and return traffic 
```bash
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT

```
### 3. enable ip forwarding on ubuntu vm
```bash
sysctl -w net.ipv4.ip_forward=1
 echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
```

## ubuntu client 2 -10.0.1.5
### enable http server on port 8000

```bash
tmux new-session -d -s httpserver "python3 -m http.server"
```


## ubuntu client 1 -10.0.1.4  send attack traffic

```bash
curl -v -m 5 -H 'User-Agent: () { :; }; /bin/ls' http://10.0.1.5:8000"
```




