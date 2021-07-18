#!/bin/bash

echo "Select OS to install Intel MAS CLI Tool: "
options=("CentOS" "Debian/Ubuntu" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CentOS")
            rpm -Uvh "http://185.238.170.43:8639/cTKZmhaaRR4/intelmas.rpm" && intelmas show -intelssd && echo -e "See ID of drive and execute this command to update FW:\nintelmas load -intelssd <ID>"
            break
            ;;
        "Debian/Ubuntu")
            apt install wget -y ; wget "http://185.238.170.43:8639/cTKZmhaaRR4/intelmas.deb" && dpkg -i intelmas.deb && rm -f intelmas.deb && intelmas show -intelssd && echo -e "See ID of drive and execute this command to update FW:\nintelmas load -intelssd <ID>"
            break            
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
