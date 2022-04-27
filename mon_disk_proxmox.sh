#!/bin/bash
sed -i 's/deb /#deb /g' /etc/apt/sources.list.d/pve-enterprise.list
cat > /etc/apt/sources.list << EOF
deb http://ftp.debian.org/debian bullseye main contrib
#deb http://ftp.debian.org/debian bullseye-updates main contrib

# PVE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription

# security updates
#deb http://security.debian.org/debian-security bullseye-security main contrib
EOF
apt install pciutils dmidecode smartmontools lshw wget python -y
wget -O /opt/smart.py http://prounix.pw/smartd.py
mkdir /var/log/smart
H=$(shuf -i 3-7 -n 1)
M=$(shuf -i 0-60 -n 1)
cat > /etc/cron.d/check_smart << EOF
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
$M $H * * * root /usr/bin/python3 /opt/smart.py > /var/log/smart/smart.log 2>&1
EOF
service cron restart
cat > /etc/logrotate.d/smart << EOF
/var/log/smart/smart.log
{
    rotate 30
    daily
    missingok
    dateext
    copytruncate
    notifempty
    compress
}
EOF
/usr/bin/python3 /opt/smart.py > /var/log/smart/smart.log 2>&1
cat /var/log/smart/smart.log
rm -f mon_disk_debian.sh
