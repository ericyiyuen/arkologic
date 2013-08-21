#!/bin/bash

./script_uo/create_restore_menu.sh
cp -f restore.menu /tftpboot/pxelinux.cfg
