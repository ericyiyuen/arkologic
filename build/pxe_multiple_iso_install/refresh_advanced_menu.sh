#!/bin/bash

iso_home=/mnt/isostore
for i in $iso_home/*.iso; do
    echo $i
    iso_version=$(basename $i | sed  -e 's/\.\(iso\|ISO\)$//')
    if [[ x != x"$iso_version" ]]; then
        #script_uo is in this dir
        /home/goldenimage/script_uo/add_iso_to_advanced_menu $iso_version
    fi
done
