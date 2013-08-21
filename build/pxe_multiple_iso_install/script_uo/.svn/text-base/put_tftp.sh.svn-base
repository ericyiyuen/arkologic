#!/bin/bash

AWK=/usr/bin/nawk

SRC=$1
DST=$2

server_ip=`prtconf -v | sed -n '/install_server/{;n;p;}' | $AWK -F "'" '{print $2}' | $AWK -F ":" '{print $1}'`

echo "put $SRC $DST" > tftp.cmd

tftp $server_ip < tftp.cmd

