#!/bin/bash
#**********************************************************************
# file: gen_ha_licence.sh
# date: 2013-06-27 14:56
# author: (c) by Eric Yuan - <ericy@arkologc.com>
# description: send, get and process a response email from ha.com and extract licence files
# **********************************************************************

if [ "$#" -lt 2 ]
then
    echo "Usage: $0 [-i licence_id] [-e expiry_date] [hostid1] [hostid2]"
    exit 1
fi

while getopts ":i:e:" Option
do
    case $Option in
        i ) arko_licence_id=$OPTARG
        ;;
        e ) arko_expiry_date=$OPTARG
        ;;
    esac
done

shift $(($OPTIND - 1))

# Load bsfl lib
test -f eric_lib/bsfl.inc.sh && source eric_lib/bsfl.inc.sh || exit 1

# Load string lib
test -f eric_lib/string.inc.sh && source eric_lib/string.inc.sh || exit 1
GET_EMAIL_USER="arko"
NEW_EMAIL_HOME="/home/arko/mail/new"
CUR_EMAIL_HOME="/home/arko/mail/cur"
OUTPUT_HOME="/eric_scripts/output" 
ARKO_LICENCE_HOME="/home/arko/arkolicense_1_99"
SEND_HA_EMAIL_PROGRAM="send_ha_request_email"
MUNPACK_BIN="/usr/local/bin/munpack"
LOG_FILE="/eric_scripts/logs/gen_ha_licence.log"
LOG_ENABLED=y
WAIT_TIME="10"
RETRY_TIMES="10"

hostid1=$1
hostid2=$2
arko_licence_id=${arko_licence_id-ArkoDev}
arko_expiry_date=${arko_expiry_date-9999-12-31}


# Verify hostids
if ! is_alphanumeric "$hostid1" ;
    then echo "bad chars in hostid $hostid1"; exit 1;
fi

if ! is_alphanumeric "$hostid2" ;
    then echo "bad chars in hostid $hostid2"; exit 1;
fi

mkdir -p $OUTPUT_HOME

test -d $ARKO_LICENCE_HOME || 
{ 
    msg_error "no arko licence home found!"; 
    exit 1; 
}

cd $NEW_EMAIL_HOME || exit 1

# Move all current new emails into cur folder
msg_info "Emptying $NEW_EMAIL_HOME"
mv $NEW_EMAIL_HOME/* $CUR_EMAIL_HOME &>/dev/null

msg_info "Sending request email hostid1: $hostid1, hostid2: $hostid2"
$SEND_HA_EMAIL_PROGRAM $hostid1 $hostid2 &> /dev/null || 
{ 
    msg_fail "error with sending email"; 
    exit 1;
}

msg_success "successfuly sent request email"
retry=0
email_file=''
while [ $retry -lt $RETRY_TIMES ]; do
    su - $GET_EMAIL_USER -c "getmail -ql"  1>/dev/null
    email_file=`grep -rl -E "$hostid1.*$hostid2"  . | head -n1` 
    if [ -n "$email_file" ]; then
        echo $email_file;
        break;
    else 
        (( $retry != $RETRY_TIMES )) && \
        msg_info "The response email has arrived yet, retrying" 
        sleep $WAIT_TIME
        (( retry++ ))
    fi
done

if ! [ -n "$email_file" ]; then
    msg_fail "error with getting email"; 
    exit 1
fi

msg_success "successfuly got response email `readlink -m $email_file`"

msg_info "Extracting licence files from email file" 
$MUNPACK_BIN $email_file

hostid1_licence_file="$NEW_EMAIL_HOME/license.$hostid1"
hostid2_licence_file="$NEW_EMAIL_HOME/license.$hostid2"
[ -e $hostid1_licence_file ] || 
{ 
    msg_fail "hostid1 licencefile not found: $hostid1_licence_file"; 
    exit 1;
}
[ -e $hostid2_licence_file ] || 
{ 
    msg_fail "hostid2 licencefile not found: $hostid2_licence_file"; 
    exit 1;
}    

cp $hostid1_licence_file $OUTPUT_HOME
cp $hostid2_licence_file $OUTPUT_HOME

msg_success "successfuly got ha licence files "

msg_info "begin to generate arkologic HA licence file"
cd $ARKO_LICENCE_HOME

./genlicfile -i $arko_licence_id \
-p "$OUTPUT_HOME/${arko_licence_id}_ha_licfile" \
-f "ha enabled $arko_expiry_date \
$hostid1_licence_file \
$hostid2_licence_file" ||
{
    msg_fail "generation of arkologic HA licence file failed";
    exit 1;
}    


msg_success "successfuly generated arkologic HA licence file ${arko_licence_id}_ha_licfile"

