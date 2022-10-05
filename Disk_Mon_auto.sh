#!/bin/bash

# Detect OS distributive name
OS=$(cat /etc/os-release | grep "^ID=" | sed 's/ID=//g' | sed 's/"//g')

# If OS is CentOS then detect version
        if [ "${OS}" = "centos" ]; then
	OSver=$(cat /etc/os-release | grep 'VERSION_ID' | sed 's/VERSION_ID=//g' | sed 's/"//g')
                if [ "${OSver}" = "7" ]; then
                echo "Run for CentOS 7"
		yum install curl -y
		curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_centos.sh" | sh && echo "Done"
                else
			if [ "${OSver}" = "8" ]; then
                        echo "Run for CentOS 8"
			yum install curl -y
			curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_centos8.sh" | sh && echo "Done"
			fi
                fi
        else

#If OS is Debian based then run command
                if [ "${OS}" = "debian" ] || [ "${OS}" = "ubuntu" ]; then
		OSver_deb=$(cat /etc/lsb-release | grep 'DISTRIB_RELEASE' | awk -F\= '{print $2}')
			if [ "${OS}" = "ubuntu" ] & [ "${OSver_deb}" = "22.04" ]; then
			echo "Run for ${OS} ${OSver_deb}"
			apt update
			apt install curl -y
			curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_ubuntu22.sh" | sh && echo "Done"
	               
		else
                        echo "Run for ${OS} ${OSver_deb}"
                        apt update
                        apt install curl -y
                        curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_deb.sh" | sh && echo "Done"
                        fi
fi
#If OS is AlmaLinux
			if [ "${OS}" = "almalinux" ]; then
                        echo "Run for AlmaLinux"
                        yum install curl -y
                        curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_centos8.sh" | sh && echo "Done"
                        fi

#If OS is Sangoma
                        if [ "${OS}" = "sangoma" ]; then
                        echo "Run for Sangoma Linux"
                        yum install curl -y
                        curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_centos.sh" | sh && echo "Done"
                        fi
        fi


rm -f dm.sh
