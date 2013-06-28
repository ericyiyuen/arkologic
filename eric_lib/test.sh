#!/bin/bash

# Load this file in your main script:
test -f ./mysql.inc.sh && source ./mysql.inc.sh || exit 1

dbHostname="db3"
dbUsername="beecrazy"
dbPassword="vmniDlw57e1XwhWbQFilbioIyzIWloij"
dbDatabase="beecrazy"
# Select all rows from table 'users'.
rows=$( rc_mysql_query "SELECT" "$dbHostname" \
                           "$dbUsername" "$dbPassword" \
                           "$dbDatabase" "SELECT id, name FROM deals LIMIT 3" )


# Convert the result '$rows' in an array row[].
mysql_fetch_rows "$rows"

# Loop array row[] and split line by pipe character.
for (( i=0; i<${#row[@]}; i++ )); do
    #echo ${row[$i]}
	id=$( echo ${row[$i]} | cut -d'|' -f1 )
	dealname=$( echo ${row[$i]} | cut -d'|' -f2 )
	echo "\$id: $id; \$name: $dealname"
done
