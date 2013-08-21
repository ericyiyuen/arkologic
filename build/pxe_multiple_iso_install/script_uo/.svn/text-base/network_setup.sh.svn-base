#!/bin/bash

IF=`cat /tmp/network.log | nawk -F "/" '{print $1}'`
IP=`cat /tmp/network.log | nawk '{print $2}'`

sleep 5

echo "Waiting for Network Ready!"
while true
do
	AUTOFS=`svcs -v | grep autofs | grep online`
	if [ -n "$AUTOFS" ]
	then
		echo "Netowrk Ready!"
		break
	fi
	sleep 1
done

echo "Creating IP"

if true
then
	# Create Static IP 
	/usr/sbin/ipadm create-addr -T static -a local=$IP $IF/mgmtport > /dev/msglog 2>&1
else
	# Create Dynamic IP
	/usr/sbin/ipadm create-addr -T dhcp $IF/mgmtport
	route add -net 192.168.234.0 192.168.91.2 -ifp igb0
fi

install_server=`prtconf -v | sed -n '/install_server/{;n;p;}' | /usr/bin/nawk -F "'" '{print $2}'`

echo "Mounting NFS"

mount -F nfs -o vers=3 $install_server /tmp/share

echo "Mounted NFS"

