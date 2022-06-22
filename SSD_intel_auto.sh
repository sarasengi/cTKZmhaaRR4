#!/bin/bash

# Detect OS distributive name
OS=$(cat /etc/os-release | grep "^ID=" | sed 's/ID=//g' | sed 's/"//g')

# If OS is CentOS then install rpm package
        if [ "${OS}" = "centos" ] || [ "${OS}" = "almalinux" ]; then
	yum install wget -y
	rpm -Uvh "http://185.238.170.43:8639/cTKZmhaaRR4/intelmas.rpm" && intelmas show -intelssd && echo -e "See ID of drive with old FW and execute this command to update:\nintelmas load -intelssd <ID>\n\nIf Hrdware RAID installed execute this commands to list drives and update:\nintelmas set -system EnableLSIAdapter='true'\nintelmas show -intelssd\nintelmas load -intelssd <ID>"
        else

#If OS is Debian based then install deb package
                if [ "${OS}" = "debian" ] || [ "${OS}" = "ubuntu" ]; then
		echo "Run for Debian/Ubuntu"
		apt install wget -y
		wget "http://185.238.170.43:8639/cTKZmhaaRR4/intelmas.deb" && dpkg -i intelmas.deb && rm -f intelmas.deb && intelmas show -intelssd && echo -e "See ID of drive with old FW and execute this command to update:\nintelmas load -intelssd <ID>\n\nIf Hrdware RAID installed execute this commands to list drives and update:\nintelmas set -system EnableLSIAdapter='true'\nintelmas show -intelssd\nintelmas load -intelssd <ID>"
                fi
        fi
rm -f ssd.sh
