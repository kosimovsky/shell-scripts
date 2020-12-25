#!/bin/bash

decode_json(){
	echo `echo $1 \
		| sed 's/{\"data\"\:{//g' \
		| sed 's/\\\\\//\//g' \
		| sed 's/[{}]//g' \
		| awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' \
		| sed 's/\"\:\"/\|/g' \
		| sed 's/[\,]/ /g' \
		| sed 's/\"// g' \
		| grep -w $2 \
		| awk -F "|" '{print $2}'`
}

USERNAME="root@pam"
read -p "Enter password: " PASS
HOST="https://10.3.28.70:8006"
DATA=`curl -s -k -d "username=$USERNAME&password=$PASS" $HOST/api2/json/access/ticket`
TICKET=$(decode_json $DATA "ticket")
CSRF=$(decode_json $DATA "CSRFPreventionToken")
