#!/bin/sh
mrun="mysql -u ${ZS_DBUser} -p${ZS_DBPassword} -h ${ZS_DBHost} -P ${ZS_DBPort} -D ${ZS_DBName}"
SQLCMD="CALL partition_maintenance_all(\"${ZS_DBName}\",${ZS_DBPartKeepData},${ZS_DBPartKeepTrends});"

echo "$( date ): Starting Zabbix Database maintenance"
$mrun -e "$SQLCMD"
echo "$( date ): Zabbix Database maintenance completed"
