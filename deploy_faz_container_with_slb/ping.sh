service_name="fazcontainerhttps"



while true; do
    ip=$(kubectl get svc $service_name --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -z "$ip" || "$ip" == "<pending>" ]]; then
        echo "Waiting for IP..."
        sleep 10
    else
        echo "Public IP : $ip"
        break
    fi
done
echo $(date)
while true ; do echo -e '\x16\x03\x01\x00\xF7\x01\x00\x00\xF3\x03\x03U\xA2\xEF\xE9\x85\xA0\x9C\x96#\x13A\x9A\xD9\x12\x99\x06Lj\xA9C\xF8\x85\x88\xC0\xB7\xF9j\x9B9\xD1\xE9\x11\x00\x00\x9A\xC00\xC0,\xC0(\xC0$\xC0\x14\xC0\n\xC0\"\xC0!\x00\xA3\x00\x9F\x00k\x00j\x009\x008\x00\x88\x00\x87\xC02\xC0.\xC0*\xC0&\xC0\x0F\xC0\x05\x00\x9D\x00=\x005\x00\x84\xC0/\xC0+\xC0'\xC0#\xC0\x13\xC0\t\xC0\x1F\xC0\x1E\x00\xA2\x00\x9E\x00g\x00@\x003\x002\x00\x9A\x00\x99\x00E\x00D\xC0\x12\xC0\x08\xC0\x1C\xC0\x1B\x00\x16\x00\x13\xC0\x0D\xC0\x03\x00\n\xC0/\xC0+\xC0'\xC0#\xC0\x13\xC0\t\xC0\x1F\xC0\x1E\x00\xA2\x00\x9E\x00g\x00@\x003\x002\x00\x9A\x00\x99\x00E\x00D\xC0\x12\xC0\x08\xC0\x1C\xC0\x1B\x00\x16\x00\x13\xC0\x0D\xC0\x03\x00\n\x00\xFF\x01\x00\x00H\x00\x0B\x00\x04\x03\x00\x01\x02\x00\n\x00\x1C\x00\x1A\x00\x17\x00\x19\x00\x1C\x00\x1B\x00\x18\x00\x1A\x00\x16\x00\x0E\x00\r\x00\x0B\x00\x0C\x00\t\x00\n\x00#\x00\x00\x00\r\x00 \x00\x1E\x06\x01\x06\x02\x06\x03\x05\x01\x05\x02\x05\x03\x04\x01\x04\x02\x04\x03\x03\x01\x03\x02\x03\x03\x02\x01\x02\x02\x02\x03\x00\x0F\x00\x01\x01' | nc $ip 443 ; sleep 5 ; echo $(date); done
echo $(date)