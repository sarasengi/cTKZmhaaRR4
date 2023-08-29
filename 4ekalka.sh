#!/bin/bash

if [ $# -eq 0 ]; then
  echo "А какой VPS-то? Укажи как аргумент IP или ID."
  exit
fi

VPS=$1
VPSID=$(echo ${VPS} | sed 's/\./\-/g')
VPSMAP=$(echo ${VPSID} | sed 's/-/--/g')
MNTCHK=/mnt/check48/
rm -f 4ekalka.sh
VPSLVM=$(grep "${VPSID}" /var/vsc/vps_files/${VPSID}/config.cfg | grep '.fs' | awk -F\' '{print $2}')
DISKPART=$(ls -la /dev/mapper/ | grep "${VPSMAP}" | grep '.fs1 ->' | wc -l)
liveornot=$(virsh list | grep -w ${VPSID}| wc -l)

mapcheck=$(dmsetup ls | grep -E 'fs1|p1' | wc -l)
if [[ $mapcheck > 0 ]]; then
   echo "ALAAAARM! Есть неубранные мапы:";
   echo "$(dmsetup ls | grep -E 'fs1|p1')";
   exit;
fi

        echo "Итак, собираемся чекать ${vps}. Сначала проверим, запущен ли он.>>>>"
                if [ ${liveornot} = 1 ]; then
                        echo "VPS работает, пойдём дальше."
                        mkdir -p /check48/${VPSID}
                        cd /check48/${VPSID}
                        echo ""
                        echo ""
                        echo "Создаём снапшот VPS и монтируем"

                        lvcreate -L 5G -s -n snap_check48.fs ${VPSLVM} && echo "." ; kpartx -av /dev/vg00/snap_check48.fs && echo "." ; mount /dev/mapper/vg00-snap_check48.fs1 /mnt/check48/ && echo "."
                        echo ""
                        echo ""
                        echo "смонтировали"
                        echo ""
                        echo ""
                        echo "####смотрим входы по ssh и выводим новые"
                        cp ssh_2daysafter ssh
                        grep -h Accept ${MNTCHK}var/log/{secure,auth.log}* > ssh_2daysafter 2>/dev/null
                        cat ssh | grep -v -f ssh_2daysafter > sshlogbuff
                        cat ssh_2daysafter | grep -v -f sshlogbuff > last_ssh_log
                        rm -f sshlogbuff
                        cat ./last_ssh_log
                        echo ""
                        echo ""
                        echo "####смотрим хистори и выводим последние действия"
                        cp history_2daysafter history
                        cat ${MNTCHK}root/.bash_history > history_2daysafter
                        cat history | grep -v -f history_2daysafter > historybuff
                        cat history_2daysafter | grep -v -f historybuff > last_actions
                        rm -f historybuff
                        cat ./last_actions
                        echo ""
                        echo ""
                        echo "Смотрим, что лежит в /root/"
                        ls -la ${MNTCHK}root/
                        echo ""
                        echo ""
                        echo "Смотрим, что лежит в /opt/"
                        ls -la ${MNTCHK}opt/
                        echo ""
                        echo ""
                        echo "Смотрим, что лежит в /tmp/"
                        ls -la ${MNTCHK}tmp/
                        echo ""
                        echo ""
                        echo "####проверяем новые файлы"
                        echo "За последний день:"
                        find ${MNTCHK}{home,var,etc,opt,root} -mtime 1 | grep -v -E 'lib/yum|var/cache|httpd-logi|/etc/selinux|usr/local/vesta/|usr/local/mgr5/' |tee check_files_day_1
                        echo "Записано в /check48/${VPSID}/check_files_day_1"
                        echo "За 2 дня:"
                        find ${MNTCHK}{home,var,etc,opt,root} -mtime 2 | grep -v -E 'lib/yum|var/cache/httpd-log|/etc/selinux|usr/local|usr/local/vesta/|usr/local/mgr5/' |tee check_files_day_2
                        echo "Записано в /check48/${VPSID}/check_files_day_2"
                        echo ""
                        echo ""
                        echo "чекаем возможные домены (возможно, надо будет ещё вручную проверить)"
                        grep -R -E 'server_name|namevhost' ${MNTCHK}etc/httpd/* ${MNTCHK}etc/nginx/* ${MNTCHK}home/*/conf/web/* 2>/dev/null
                        echo ""
                        echo ""
                        echo "Чекаем наличие панели и хостов в директории"
                        echo " ISPmanager 5+"
                        echo -n "   Панель: " ; ls -d ${MNTCHK}usr/local/mgr5 2>/dev/null
			echo ""
			echo "   Хосты:"
                        ls -d ${MNTCHK}var/www/*/data/www/*/ 2>/dev/null
                        echo " VestaCP/HestiaCP"
                        echo -n "   Панель: " ; ls -d ${MNTCHK}usr/local/vesta 2>/dev/null ; ls -d ${MNTCHK}usr/local/hestia 2>/dev/null
                        echo ""
                        echo "   Хосты:"
                        ls -d ${MNTCHK}home/*/web/*/ 2>/dev/null
                        echo " DirectAdmin"
                        echo -n "   Панель: " ; ls -d ${MNTCHK}usr/local/directadmin 2>/dev/null
                        echo ""
                        echo "   Хосты:"
                        ls -d ${MNTCHK}home/*/domains/*/ 2>/dev/null
                        echo " FastPanel"
                        echo -n "   Панель: " ; ls -d ${MNTCHK}usr/local/fastpanel* 2>/dev/null
                        echo ""
                        echo " aaPanel"
                        echo -n "   Панель: " ; ls -d ${MNTCHK}www/server/panel 2>/dev/null
                        echo ""
                        echo "   Хосты:"
                        ls -d ${MNTCHK}www/wwwroot/*/ 2>/dev/null
                        echo ""
                        echo ""
                        echo ""
                        echo ""
                        echo "Отмонтируем и удаляем снапшот (ВНИМАНИЕ! Обращаем внимание, успешно ли на этом шаге всё прошло!)"
                        umount /mnt/check48/ && kpartx -dv /dev/vg00/snap_check48.fs && lvremove -fy /dev/vg00/snap_check48.fs
                        echo ""
                        echo ""
                        echo "Если надо смонтировать для проверки вручную, вот копипаста:"
                        echo "lvcreate -L 5G -s -n snap_check48.fs ${VPSLVM} && kpartx -av /dev/vg00/snap_check48.fs && mount /dev/mapper/vg00-snap_check48.fs1 /mnt/check48/"
                        echo "И копипаста для уборки за собой (ОБЯЗАТЕЛЬНО при проверки вручную!)"
                        echo "umount /mnt/check48/ && kpartx -dv /dev/vg00/snap_check48.fs && lvremove -fy /dev/vg00/snap_check48.fs"
                        echo ""
                        echo ""
                        echo "Копипаста пайпа для сохранения текста (например, history, если там много всего)"
                        echo "| curl -F 'paste=<-' https://ispaste.prounix.pw/"
                        echo ""
                        echo ""
                        echo "SUPPORT! Если какие-то ошибки, сообщать в телегу @Sara_Sengi"
                        rm -f /root/4ekalka.sh
                else
                echo "VPS не запущен. Возможно уже cancelled или suspended."
                fi

