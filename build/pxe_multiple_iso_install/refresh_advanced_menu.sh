#!/bin/bash

iso_home=/mnt/isostore
cd $iso_home
iso_list=$(find . -maxdepth 1 -regextype posix-extended -regex '.*/[0-9\.].*.iso')
for i in $iso_list; do
    echo $i
    iso_version=$(basename $i | sed  -e 's/\.\(iso\|ISO\)$//')
    if [[ x != x"$iso_version" ]]; then
        /home/goldenimage/script_uo/add_iso_to_advanced_menu $iso_version
    fi
done
