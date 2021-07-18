#!/bin/bash

echo "Select OS: "
options=("CentOS 6/7" "CentOS 8" "Debian/Ubuntu" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "CentOS 6/7")
            yum install curl -y ; curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_centos.sh" | sh && echo "Done"
            break
            ;;
        "CentOS 8")
            yum install curl -y ; curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_centos8.sh" | sh && echo "Done"
            break
            ;;
        "Debian/Ubuntu")
            apt install curl -y ; curl "https://raw.githubusercontent.com/sarasengi/cTKZmhaaRR4/master/mon_disk_deb.sh" | sh && echo "Done"
            break            
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
