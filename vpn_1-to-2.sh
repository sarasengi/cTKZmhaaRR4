#!/bin/bash 
iplist=ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1 | rev | cut -d/ -f1 | rev 
ip1=echo $iplist | cut -d " " -f1
ip2=echo $iplist | cut -d " " -f2
sed -i "s/$ip1/$ip2/g" /etc/sysconfig/iptables
sed -i "s/$ip1/$ip2/g" /var/www/html/*/wg_client*
cd /var/www/html/*/ && rm -f all.zip *.png && find . -iname '*.conf' -exec sh -c " cat {} |  qrencode -t PNG -o {}.png" \; && zip all.zip *
systemctl restart iptables && systemctl restart wg-quick@wg00.service
sed -i "/external/d" /etc/3proxy.cfg && sed -i "/internal/d" /etc/3proxy.cfg && sed -i "/socks/d" /etc/3proxy.cfg
echo socks -n -e$ip2 -i$ip1 -p50080 -a >> /etc/3proxy.cfg
rm -f /root/vpn12.sh
