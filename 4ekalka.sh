#!/bin/bash
VPSID=$1
VPSMAP=$(echo $VPSID | sed 's/-/--/g')
MNTCHK=/mnt/check48/
mkdir -p /check48/${VPSID}
rm -f 4ekalka.sh
cd /check48/${VPSID}
echo ""
echo ""
echo "#монтируем"
mkdir ${MNTCHK}
kpartx -av /dev/vg*/*${VPSID}.fs
echo "."
mount -o ro /dev/mapper/*${VPSMAP}.fs1 ${MNTCHK}
echo ".."
echo "смонтировали"
echo ""
echo ""
echo "#смотрим входы по ssh и выводим новые"
cp ssh_2daysafter ssh
grep -h Accept ${MNTCHK}var/log/{secure,auth.log}* |tee ssh_2daysafter
cat ssh | grep -v -f ssh_2daysafter |tee sshlogbuff
cat ssh_2daysafter | grep -v -f sshlogbuff > last_ssh_log
rm -f sshlogbuff
echo ""
echo ""
echo "#смотрим хистори и выводим последние действия"
cp history_2daysafter history
cat ${MNTCHK}root/.bash_history |tee history_2daysafter
cat history | grep -v -f history_2daysafter > historybuff
cat history_2daysafter | grep -v -f historybuff > last_actions
rm -f historybuff
echo ""
echo ""
echo "#проверяем новые файлы"
echo "За последний день:"
find ${MNTCHK}{home,var,etc,opt,root} -mtime 1 | grep -v -E 'lib/yum|var/cache|httpd-logi|/etc/selinux|usr/local/vesta/|usr/local/mgr5/' |tee 1day_files
echo "За 2 дня:"
find ${MNTCHK}{home,var,etc,opt,root} -mtime 2 | grep -v -E 'lib/yum|var/cache/httpd-log|/etc/selinux|usr/local|usr/local/vesta/|usr/local/mgr5/' |tee 2days_files
echo ""
echo ""
echo "#чекаем возможные домены, надо будет ещё вручную проверить"
grep -Rils 'server_name' ${MNTCHK}etc/nginx/* ${MNTCHK}usr/local/* |tee check_domains_nginx
grep -Rls 'ServerName' ${MNTCHK}etc/httpd/* ${MNTCHK}etc/apache2/* ${MNTCHK}usr/local/* |tee check_domains_apache
echo ""
echo ""
echo "#Чекаем наличие панели"
ls -d ${MNTCHK}usr/local/{mgr5,ispmgr,vesta,directadmin,fastpanel*}
echo ""
echo ""
echo "#отмонтируем"
umount ${MNTCHK}
echo "."
kpartx -dv /dev/vg*/*${VPSID}.fs
echo ".."
echo ""
echo ""
echo "Если надо смонтировать для проверки вручную, вот копипаста для монтирования:"
echo "kpartx -av /dev/vg*/*${VPSID}.fs ; mount -o ro /dev/mapper/*${VPSMAP}.fs1 ${MNTCHK}"
echo ""
echo "Копипаста для отмонтирования (ОБЯЗАТЕЛЬНО!)"
echo "umount ${MNTCHK} ; kpartx -dv /dev/vg*/*${VPSID}.fs"

echo ""
echo ""
echo "| curl -F 'paste=<-' https://ispaste.prounix.pw/"
rm -f 4ekalka.sh
