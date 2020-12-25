#!/bin/bash

CWD=/etc/zabbix/scripts

FILE=$CWD/check_oom

if [ ! -e $FILE ]; then
	sudo -u zabbix touch $FILE
fi

BEFORE=$(wc -l $FILE)

dmesg | grep -i "killed process" > $FILE

AFTER=$(wc -l $FILE)

if [[ $BEFORE == $AFTER ]]; then
	echo 0
else 
	echo 1
fi

exit 0