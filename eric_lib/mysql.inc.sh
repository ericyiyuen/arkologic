# *********************************************************
# file: mysql.inc.sh
# date: 2012-08-22 14:56
# author: (c) by Eric Yuan - <ericyiyuen@gmail.com>
# description: Little mysql library for bash.
# *********************************************************
#
#
# SYNOPSIS
#
#    # Load this file in your main script:
#    test -f ./mysql.inc.sh && source ./mysql.inc.sh || exit 1
#
#    # Update table 'users'.
#    if ! rc_mysql_query "UPDATE" "$dbHostname" "$dbUsername" \
#                                 "$dbPassword" "$dbDatabase" \
#                                 "UPDATE users SET email='info@test.de' WHERE id=1" ; then
#        echo "MySQL Statement fehlgeschlagen!"
#    fi
#
#    # Select all rows from table 'users'.
#    rows=$( rc_mysql_query "SELECT" "$dbHostname" \
#                           "$dbUsername" "$dbPassword" \
#                           "$dbDatabase" "SELECT * FROM users ORDER BY id ASC" )
#
#
#    # Convert the result '$rows' in an array row[].
#    mysql_fetch_rows "$rows"
#
#    # Loop array row[] and split line by pipe character.
#    for (( i=0; i<${#row[@]}; i++ )); do
#        id=$( echo ${row[$i]} | cut -d'|' -f1 )
#        username=$( echo ${row[$i]} | cut -d'|' -f3 )
#        echo "\$id: $id; \$username: $username"
#    done
#
#    # This sample get the next insert id of the auto_increment field of table 'users'.
#    nextid=$( rc_mysql_nextid "$dbHostname" "$dbUsername" "$dbPassword" "$dbDatabase" "users" )
#
#
#
# *********************************************************
# This function send a MySQL query. For type of SQL statements
# like, INSERT, UPDATE, DELETE, DROP, etc, rc_mysql_query()
# returns TRUE on success or FALSE on error. For other type
# of SQL statements like SELECT, SHOW, DESCRIBE, EXPLAIN
# rc_mysql_query() returning the result.
 
function rc_mysql_query () {
 
local status=$1
local hostname=${2:-"localhost"}
local username=$3
local password=$4
local database=$5
local query=$6
local error="/tmp/mysql_query.err"
 
# Execute the statement INSERT|UPDATE|REPLACE|DELETE|DROP and return the number of affected rows from ROW_COUNT().
if [ "$status" = "INSERT" -o "$status" = "UPDATE" -o "$status" = "REPLACE" -o "$status" = "DELETE" -o "$status" = "DROP" ]; then
	local res=$( mysql	--user=$username \
						--password=$password \
						--database=$database \
						--host=$hostname \
						--line-numbers --no-beep -Bse "$query; SELECT ROW_COUNT();" 2>$error )
 
	# Return true if affected rows greater than 0.
	##[ "$res" -ne 0 ] && true || false
 
	# Return true if no error in error file.
	if [ "$( cat $error | wc -l )" -ne 0 ]; then
		[ -f "$error" ] && rm -f $error; false
	else
		[ -f "$error" ] && rm -f $error; true
	fi
else
 
	# Execute the statement and return the result.
	local res=$( mysql --user=$username \
					--password=$password \
					--database=$database \
					--host=$hostname \
					--line-numbers --no-beep --column-names -Bse "$query" 2>$error )
 
	# Return the result if no error in error file.
	if [ "$( cat $error 2>/dev/null | wc -l )" -ne 0 ]; then
		if [ -f "$error" ]; then
			cat $error; rm -f $error; exit 1
		fi
	else
		echo -e "$res"
	fi
 
 
fi
 
}
 
# *********************************************************
# This function call the MySQL statement (SHOW TABLE STATUS LIKE '<TABLENAME>')
# and return the value of a defined key (e.g. auto_increment).
 
function rc_mysql_status () {
 
local hostname=${1:-"localhost"}
local username=$2
local password=$3
local database=$4
local table=$5
local object=$6
local error="/tmp/mysql_status.err"
 
# Execute the statement and return the result.
local res=$( mysql --user=$username \
					--password=$password \
					--database=$database \
					--host=$hostname \
					--column-names --skip-auto-rehash -Be "SHOW TABLE STATUS LIKE '$table'" 2>$error )
 
# Return the value of the defined key if no error in file.
if [ "$( cat $error 2>/dev/null | wc -l )" -ne 0 ]; then
	if [ -f "$error" ]; then
		cat $error; rm -f $error; exit 1
	fi
else
	echo -e "$res" | \
		perl -ne '
		BEGIN {
		use strict;
		use vars qw( $obj @data );
		$obj="'$object'";
		}
 
		my @tmp = split( /\s+/, $_ );
		push( @data, [@tmp] );
 
		END {
 
		my $index=0;
		for my $x ( 0 .. ($#data+1) ) {
			foreach my $y( 0 .. (@{$data[$x]}+1) ) {
				$index = $y if ( lc($data[0][$y]) eq "$obj" );
			}
		}
 
		print $data[1][$index]."\n";
 
		}'
fi
 
}
 
# *********************************************************
# This function convert the raw returned mysql data as
# an numeric array row[]. This is an simulated two
# dimensional array seperated by pipe character.
#
# EXAMPLE:
#	row[0]="1|Fred Feuerstein|ffeuerstein|ffeuerstein@feuerstein.com"
#	row[1]="2|Barney Geroellheimer|bgeroellheimer|bgeroellheimer@feuerstein.com"
 
function mysql_fetch_rows () {

unset row
 
local data="$*"
 
# This perl snippet convert the raw data in array row[].
array=$( echo -e "$data" | perl -ne '
BEGIN { $i=0; }
 
# We jump to the next line if this is a empty line.
next if $_ =~ m/^$/;
 
# Remove newlines, spaces and other charcters.
$_ = conv_chars( $_ );
 
# Convert the entry like this: "one","two","tree"
$_ =~ s/\t+/\|/g;
 
# Print out to STDOUT.
print "row[".$i."]=\"".$_."\"\n";
 
$i++;
 
sub conv_chars {
 
my $txt=shift;
$txt =~ s/\cM\n//g;
$txt =~ s/\n\cM//g;
$txt =~ s/\cM//g;
$txt =~ s/\s+$//g;
return $txt;
 
}
' )

#echo $array
# To use the array row[] in this script
# we have to eval this ;-)
eval $array
 
}
 
# *********************************************************
# This function return the next insert id of an
# auto_increment field of the defined mysql table.
 
function rc_mysql_nextid () {
 
local hostname=${1:-"localhost"}
local username=$2
local password=$3
local database=$4
local table=$5
 
rc_mysql_status  "$dbHostname" "$dbUsername" "$dbPassword" "$dbDatabase" "$table" "auto_increment"
 
}

function is_result_empty () {
 : ${1?"Usage: function is_result_empty [data]"}
[[ $1 =~ "^[ \n\t]*$" || $1 =~ "^ERROR" ]]
} 
# *********************************************************
# EOF
