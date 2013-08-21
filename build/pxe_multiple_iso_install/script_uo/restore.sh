#!/bin/bash

##########################
# Config 
##########################

SED=/usr/bin/sed
AWK=/usr/bin/nawk

##########################
# Checking 
##########################

base=/tmp
OUTPUT_DIR=backup_image

script_dir=$base/script
image_dir=$base/$OUTPUT_DIR

. $script_dir/helper.sh

diskdev=`/usr/sbin/cfgadm -la | $SED -n '/::dsk\/c/{p;}' | $AWK '{print $1}' | $AWK -F "/" '{print $2}'` 

if [ -z "$diskdev" ]
then
	/usr/bin/echo "Cannot find root disk"
	wait_and_shutdown
fi

##########################
# Start Restore
##########################

start_time=(`/usr/bin/date`)

/usr/bin/echo "==============================================="
/usr/bin/echo "              Restore Start"
/usr/bin/echo "==============================================="

version=`/usr/bin/cat /tmp/backup_image/image_name | $SED "s/backup_image_//g"`

if [ ! "$version" = "backup_image" ]
then
    echo "Build version = $version"
fi
	
/usr/bin/dd if=$image_dir/mbr.img of=/dev/rdsk/"$diskdev"p0
#/usr/bin/cat $image_dir/arko.img.gz.* | /tmp/script/pigz -dc | /usr/bin/pv | /usr/bin/dd of=/dev/rdsk/"$diskdev"p0 conv=sync,noerror bs=128k
/usr/bin/cat $image_dir/arko.img.gz.* | /tmp/script/pigz -dc | /usr/bin/pv | /usr/bin/dd of=/dev/dsk/"$diskdev"p0 bs=1024k
/usr/bin/echo "syncing filesystem"
sync; sync; sync

end_time=(`/usr/bin/date`)

echo "Start: ${start_time[3]}"
echo "End  : ${end_time[3]}"

$script_dir/zpool_fix

echo "Start: ${start_time[3]}"
echo "End  : ${end_time[3]}"

wait_and_shutdown
