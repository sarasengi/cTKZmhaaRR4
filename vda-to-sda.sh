#!/bin/bash
VPSID=$(echo $1 | sed 's/\./-/g')
echo "Fixing for ${VPSID} started"
VPSLVM=$(ls /dev/vg00/*${VPSID}.fs)
echo "VPS has LVM ${VPSLVM}"
VPSPRT=$(kpartx -l $VPSLVM | awk '{print $1}')
echo "and partition ${VPSPRT}"
virsh destroy ${VPSID}
echo ""
echo "VPS stopped"
kpartx -av $VPSLVM
echo ""
echo "Partition added:"
ls -la /dev/mapper/$VPSPRT
mount /dev/mapper/$VPSPRT /mnt/check48/
sed -i 's/vda1/sda1/g' /mnt/check48/etc/fstab /mnt/check48/boot/grub/grub.cfg /mnt/check48/boot/grub/grubenv /mnt/check48/boot/grub2/grubenv /mnt/check48/boot/grub2/grub.cfg
sed -i 's/vda/sda/g' /mnt/check48/boot/grub2/device.map
umount /mnt/check48
echo "vda changed to sda"
echo ""
echo "Partition hided:"
kpartx -dv $VPSLVM
sleep 5
kpartx -dv $VPSLVM
ls -la /dev/mapper/$VPSPRT
virsh create /etc/libvirt/qemu/${VPSID}.xml
echo ""
echo "VPS started"
