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

sleep 5

diskdev=(`/tmp/script/ssdtoolset/ssdstat | /usr/bin/grep off | nawk '{print $5}'`)
devices_num=${#diskdev[@]}

echo "Number of SSD is $devices_num"

if [ $devices_num != 2 ]
then
	/usr/bin/echo "Cannot find root disk"
	wait_and_shutdown
fi

##########################
# Start Restore
##########################


/usr/bin/echo "==============================================="
/usr/bin/echo "              Erase SSD Start"
/usr/bin/echo "==============================================="
	
for device in ${diskdev[@]}
do
	/tmp/script/ssdtoolset/ssderase -x -y $device
done

wait_and_shutdown
