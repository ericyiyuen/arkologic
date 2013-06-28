#! /bin/bash
DB_HOST="db3"
DB_USER="beecrazy"
DB_PASSWORD="vmniDlw57e1XwhWbQFilbioIyzIWloij"
DB_DATABASE="beecrazy"

# Load eric mysql lib
test -f /scripts/eric/mysql.inc.sh && source /scripts/eric/mysql.inc.sh || exit 1

function beecrazy_db_query {
        : ${1?"Usage: function beecrazy_db_query [sql]"}
        rc_mysql_query "SELECT" "$DB_HOST" \
                           "$DB_USER" "$DB_PASSWORD" \
                           "$DB_DATABASE" "$1"
}

