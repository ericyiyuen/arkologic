#!/bin/bash

##########################
# Config 
##########################

SED=/usr/bin/sed
AWK=/usr/bin/nawk

##########################
# Network Setup 
##########################

/tmp/script/network_setup.sh

##########################
# Checking 
##########################

base=/tmp
OUTPUT_DIR=backup_image
TMP_OUTPUT_DIR=backup_image_tmp

script_dir=$base/script
image_dir=$base/share/$OUTPUT_DIR
tmp_image_dir=$base/share/$TMP_OUTPUT_DIR

. $script_dir/helper.sh

diskdev=`/usr/sbin/cfgadm -la | $SED -n '/::dsk\/c/{p;}' | $AWK '{print $1}' | $AWK -F "/" '{print $2}'` 
disk=/dev/rdsk/"$diskdev"p0

if [ -z "$diskdev" ]
then
	/usr/bin/echo "Cannot find root disk"
	wait_and_shutdown
fi

##########################
# Start Backup
##########################

start_time=(`/usr/bin/date`)

rm -rf $tmp_image_dir
mkdir $tmp_image_dir

/usr/bin/echo "==============================================="
/usr/bin/echo "              Backup Start"
/usr/bin/echo "==============================================="
	
/usr/bin/dd if=$disk of=$tmp_image_dir/mbr.img bs=512 count=1
/usr/bin/dd if=$disk conv=sync,noerror bs=1024k | /usr/bin/pv | /tmp/script/pigz -c -4 -p 22 | split -b 2048m - /tmp/arko.img.gz.
/usr/bin/ls -lah /tmp/arko.img.gz.*
/usr/bin/cp /tmp/arko.img.gz.* $tmp_image_dir

version=`/tmp/script/get_release_version.sh`
target_dir=${image_dir}_${version}

if [ -d "$target_dir" ]
then
	echo "Folder $target_dir already exist!"
	time=`date +%Y%m%d%H%M`
	/usr/bin/mv $tmp_image_dir ${target_dir}_${time}
else
	echo "Moving folder to $target_dir"
	/usr/bin/mv $tmp_image_dir $target_dir
fi

/usr/bin/echo "syncing filesystem"
sync; sync; sync

end_time=(`/usr/bin/date`)

cd /tmp/share
/tmp/script/create_restore_menu.sh
/tmp/script/put_tftp.sh restore.menu pxelinux.cfg/restore.menu

echo "Start: ${start_time[3]}"
echo "End  : ${end_time[3]}"

wait_and_shutdown
