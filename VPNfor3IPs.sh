#!/bin/bash

IP1=$1
IP2=$2
IP3=$3
clcf=`ls -d /var/www/html/*`
echo $IP2 > /root/ips
echo $IP3 >> /root/ips

cd /etc/openvpn/server/
for i in `cat /root/ips` ; do cp server-tcp.conf from_"${IP1}"_to_$i-tcp.conf ; cp server-udp.conf from_"${IP1}"_to_$i-udp.conf ; done
mv server-tcp.conf server-tcp.conf_orig
mv server-udp.conf server-udp.conf_orig
systemctl stop openvpn-server@server-tcp.service openvpn-server@server-udp.service
systemctl disable openvpn-server@server-tcp.service openvpn-server@server-udp.service
sed -i 's/10.180.1./10.180.6./g' from_"${IP1}"_to_$IP2-tcp.conf
sed -i 's/10.180.2./10.180.7./g' from_"${IP1}"_to_$IP2-udp.conf
sed -i 's/10.180.1./10.180.8./g' from_"${IP1}"_to_$IP3-tcp.conf
sed -i 's/10.180.2./10.180.9./g' from_"${IP1}"_to_$IP3-udp.conf
sed -i 's/50000/50001/g' from_"${IP1}"_to_$IP3-tcp.conf from_"${IP1}"_to_$IP3-udp.conf

sed -i "/10.180.5.0/a-A POSTROUTING -s 10.180.6.0/24 -o eth0 -j SNAT --to-source $IP2" /etc/sysconfig/iptables
sed -i "/10.180.6.0/a-A POSTROUTING -s 10.180.7.0/24 -o eth0 -j SNAT --to-source $IP2" /etc/sysconfig/iptables
sed -i "/10.180.7.0/a-A POSTROUTING -s 10.180.8.0/24 -o eth0 -j SNAT --to-source $IP3" /etc/sysconfig/iptables
sed -i "/10.180.8.0/a-A POSTROUTING -s 10.180.9.0/24 -o eth0 -j SNAT --to-source $IP3" /etc/sysconfig/iptables
sed -i "/tcp --dport 50000/a-A INPUT -i eth0 -p tcp -m tcp --dport 50001 -j ACCEPT" /etc/sysconfig/iptables
sed -i "/udp --dport 50000/a-A INPUT -i eth0 -p udp -m udp --dport 50001 -j ACCEPT" /etc/sysconfig/iptables
systemctl restart iptables

cd /etc/openvpn/server/
for i in `ls| sed 's/\.conf//g' | grep -v server` ;  do echo $i ; systemctl enable openvpn-server@$i.service ; systemctl start openvpn-server@$i.service ; done

cp -Rp $clcf $clcf"_ORIG"

cd $clcf
mv client01-tcp.ovpn from_"${IP1}"_to_$IP2-tcp.ovpn
mv client01-udp.ovpn from_"${IP1}"_to_$IP2-udp.ovpn
mv client02-tcp.ovpn from_"${IP1}"_to_$IP3-tcp.ovpn
mv client02-udp.ovpn from_"${IP1}"_to_$IP3-udp.ovpn
sed -i 's/50000/50001/g' from_"${IP1}"_to_$IP3-tcp.ovpn from_"${IP1}"_to_$IP3-udp.ovpn

rm -f client* all.zip
zip -r ./all.zip ./*

sed -i '/10.180.5.1;/a10.180.6.1;\n10.180.7.1;\10.180.8.1;\10.180.9.1;' /etc/named.conf
sed -i '/10.180.5.0\/24;/a10.180.6.0\/24;\n10.180.7.0\/24;\n10.180.8.0\/24;\n10.180.9.0\/24;' /etc/named.conf
systemctl restart named

socks_user3_pw=$(pwgen -s 10 1)
sed -i "/usr_02/ausers usr_03:CL:$socks_user3_pw" /etc/3proxy.cfg
sed -i '/external/d' /etc/3proxy.cfg
sed -i '/internal/d' /etc/3proxy.cfg
sed -i '/socks -p50080/d' /etc/3proxy.cfg
echo "socks -e$IP1 -i$IP1 -p50080" >> /etc/3proxy.cfg
echo "socks -e$IP2 -i$IP2 -p50080" >> /etc/3proxy.cfg
echo "socks -e$IP3 -i$IP3 -p50080" >> /etc/3proxy.cfg

systemctl restart 3proxy

cd /var/www/html/
urlcfgs=`ls | grep -v 'ORIG'`
echo "OpenVPN client configs: http://$IP1:50000/$urlcfgs"
echo ""
echo "socks5:"
echo -e "$IP1:50080\n$IP2:50080\n$IP3:50080"
echo -e "usr_01 / $(grep usr_01 /etc/3proxy.cfg | awk -F\: '{print $3}')\nusr_02 / $(grep usr_02 /etc/3proxy.cfg | awk -F\: '{print $3}')\nusr_03 / $socks_user3_pw"


rm -f /root/ips /root/VPNfor3IPs.sh
