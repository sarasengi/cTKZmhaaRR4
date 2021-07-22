#!/bin/bash
dd if=/dev/zero of=/TEMPswap bs=1M count=1024
chmod 0600 /TEMPswap
mkswap /TEMPswap
swapon /TEMPswap
yum update -y
yum install -y https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
yum install yum-utils -y && yum-config-manager --enable elrepo-kernel
yum install -y kernel-ml-devel kernel-ml kernel-ml-headers
yum remove kernel-headers -y
yum install -y kernel-ml-headers
curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
yum install -y epel-release
yum install -y wireguard-dkms wireguard-tools
yum install -y bind bind-utils
mkdir /etc/wireguard
cd /etc/wireguard
umask 077
wg genkey | tee server_private_key | wg pubkey > server_public_key
wg genkey | tee client_private_key | wg pubkey > client_public_key
wgport=$(shuf -i 4000-25000 -n 1)
srvip=$(ip a | grep 'brd' | grep global | head -1 | awk '{print $2}' | awk -F\/ '{print $1}')
clprk=$(cat /etc/wireguard/client_private_key)
clpbk=$(cat /etc/wireguard/client_public_key)
sprk=$(cat /etc/wireguard/server_private_key)
spbk=$(cat /etc/wireguard/server_public_key)
cat >  /etc/wireguard/wg0.conf<< EOF
[Interface]
Address = 10.181.0.1/24
ListenPort = ${wgport}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PrivateKey = ${sprk}
SaveConfig = false

[Peer]
PublicKey = ${clpbk}
AllowedIPs = 10.181.0.2/32
EOF
iptables -A INPUT -p udp -m udp --dport ${wgport} -j ACCEPT
iptables -A INPUT -i wg0 -j ACCEPT
iptables -A INPUT -i eth0 -p udp -m udp --dport ${wgport} -j ACCEPT
iptables-save > /etc/sysconfig/iptables
sed -i 's/IPTABLES_SAVE_ON_RESTART="no"/IPTABLES_SAVE_ON_RESTART="yes"/g' /etc/sysconfig/iptables-config
cp /etc/named.conf /etc/named.conf_orig
wget -O /etc/named.conf "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/wg_named.conf"
systemctl enable named
systemctl restart named
swapoff /TEMPswap
rm -f /TEMPswap
chmod 600 /etc/wireguard/wg0.conf
systemctl enable wg-quick@wg0.service
echo "Сейчас нужно загрузиться с нового ядра, чтобы запустился WG. А для клиента конфиг такой:"
echo ""
echo "[Interface]"
echo "Address = 10.181.0.2/24"
echo "PrivateKey = ${clprk}"
echo "DNS = 10.181.0.1"
echo "[Peer]"
echo "PublicKey = ${spbk}"
echo "AllowedIPs = 0.0.0.0/0, ::/0"
echo "Endpoint = ${srvip}:${wgport}"
echo "PersistentKeepalive = 15"
