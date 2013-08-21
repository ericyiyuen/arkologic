#!/bin/bash

SED=sed
MENU=restore.menu

backup_folders=(`ls -dL backup_image_*`)
backup_num=${#backup_folders[@]}

echo "default com32/vesamenu.c32" > $MENU
echo "prompt 0" >> $MENU
echo "timeout 0" >> $MENU
echo "" >> $MENU
echo "MENU INCLUDE pxelinux.cfg/graphics.conf" >> $MENU
echo "MENU TITLE Restore Menu" >> $MENU
echo "" >> $MENU

for backup in ${backup_folders[@]}
do
	if [ -d "$backup" ] && [ ! -L "$backup" ]
	then
		backup_name=(`basename $backup`)
		version=(`echo $backup_name | $SED "s/backup_image_//g"`)
		echo "LABEL arko_restore_$version" >> $MENU
		echo "MENU LABEL Restore $version" >> $MENU
		echo "KERNEL com32/mboot.c32" >> $MENU
		echo "APPEND -solaris uo/platform/i86pc/kernel/amd64/unix -v -m verbose -B install_server=192.168.91.1:/home/goldenimage,run_mode=restore,image_name=$backup_name --- uo/boot_archive.restore" >> $MENU
		echo "" >> $MENU
    fi
done

echo "LABEL empty" >> $MENU
echo "MENU LABEL" >> $MENU
echo "" >> $MENU
echo "LABEL back_menu" >> $MENU
echo "MENU LABEL < Back" >> $MENU
echo "KERNEL com32/vesamenu.c32" >> $MENU
echo "APPEND pxelinux.cfg/graphics.conf pxelinux.cfg/default" >> $MENU
