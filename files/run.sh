#!/bin/sh
set -u
mrun="mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName}"
retry=24
MPID=0
echo "Waiting for database server"
until $mrun -e 'SELECT `itemid` FROM `item_condition` WHERE `item_conditionid` = 1' &>/dev/null; do
    echo "Waiting for database server, it's still not available"
    retry=`expr $retry - 1`
    if [ $retry -eq 0 ]; then
        echo "Database server is not available!"
        exit 1
    fi
    sleep 5
done
echo "Database server is available"

revision=$( $mrun -sN -e 'SELECT `revision` FROM `partitioning`' 2>/dev/null )
if [ ! -z $revision ] && [ $revision -eq "1" ]; then
    echo 'Partitioning already applied'
else
    echo 'Partitioning the database. It can take hours if you have much data'
    sleep 10 # just in case it can run into race condition with zabbix SQL data import
    $mrun < /usr/share/zabbix_partitioning.sql
    echo 'Partitioning completed'
fi

set -e
terminate () {
    retry=10
    echo "Caught SIGTERM signal, shutting down..."
    while ps $MPID | grep -q zbdb_maintenance; do
        echo "waiting for maintencance to finish..."
        retry=`expr $retry - 1`
        if [ $retry -eq 0 ]; then
            echo "maintencance is taking too much time, killing the process"
            kill $MPID
            break
        fi
        sleep 6
    done
    exit
}

trap terminate SIGINT SIGTERM EXIT

while true; do
    sleep $(( 60 * 60 * ${ZS_DBMaintInterval} )) &
    wait
    /usr/sbin/zbdb_maintenance.sh &
    MPID=$!
    wait $MPID
done
