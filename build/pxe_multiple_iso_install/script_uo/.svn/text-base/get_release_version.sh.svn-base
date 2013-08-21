#!/sbin/sh

SED=/usr/bin/sed
AWK=/usr/bin/nawk
ECHO=/usr/bin/echo
ZPOOL=/usr/sbin/zpool
	
$ZPOOL import > /tmp/zpool.log
$ZPOOL import -f dpool

if [ $? == 1 ]
then
	$ECHO "==============================================="
	$ECHO "   Cannot import dpool. Press ENTER to reboot"
	$ECHO "==============================================="
	/usr/bin/read
	/usr/sbin/reboot -p
fi

#DPOOL_ARKO=`/usr/sbin/zfs list | /usr/bin/grep "dpool/arkologic" | $AWK -F " " '{print $1}'`
ARKO_ROOT="dpool/arkologic"
MOUNT_PT=/mnt/pkg

/usr/sbin/zfs set mountpoint=legacy $ARKO_ROOT
/usr/sbin/mount -F zfs $ARKO_ROOT $MOUNT_PT
BUILD=`cat /mnt/pkg/release_version | /usr/bin/grep RELEASE_VERSION | $AWK -F "=" '{print $2}'`
/usr/sbin/umount $MOUNT_PT
/usr/sbin/zfs set mountpoint=/arkologic $ARKO_ROOT

$ZPOOL export -f dpool

echo "$BUILD"

