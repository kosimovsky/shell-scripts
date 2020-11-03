#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
CHRONYD="chronyd"
NTPD="ntpd"
TIMESYNCD="systemd-timesyncd"
DAEMON=""

usage () {
echo -e \\n"================================================ USAGE: ==============================================\n\n\
\t1: ${GREEN}./check_ntp ip${NC}\t\tto get host IP address.\n\
\t2: ${GREEN}./check_ntp os${NC}\t\tto get OS version.\n\
\t3: ${GREEN}./check_ntp ntp${NC}\t\tto know what NTP daemon is set.\n\
\t4: ${GREEN}./check_ntp check${NC}\t\tto check NTP daemon is running (0) or not (1).\n\
\t5: ${GREEN}./check_ntp -c delay${NC}\t\tto check ${RED}Root delay${NC} parameter.\n\
\t6: ${GREEN}./check_ntp -c strat${NC}\t\tto check ${RED}Stratum${NC} parameter.\n\
\t7: ${GREEN}./check_ntp -c systime${NC}\tto check ${RED}System time${NC} parameter.\n\
\t8: ${GREEN}./check_ntp -c server${NC}\tto check which server the host is currently synchronized with.\n\
\n======================================================================================================\n"
}

if (( $# == 0 )); then usage; fi

get_ip () {		
	IP=$(host $(hostname) | cut -d " " -f4)
	echo -e ${GREEN}$IP${NC}
}

get_os_version () {		# function for checking OS version
	VERSION=$(hostnamectl | grep -i 'operating system' | awk -F: '{print $2}')
	echo -e ${GREEN}$VERSION${NC}
}

check_service () {
	systemctl status $DAEMON | awk '/Active:/{if ($3 =="(running)") print 0; else if ( $3 =="(dead)") print 1; else print 2;}'
}

get_ntp_daemon () {
	if (( $(which chronyd &>/dev/null ; echo $?) == 0 )); then
		DAEMON=$CHRONYD
	elif (( $(which ntpd &>/dev/null ; echo $?) == 0 )); then
		DAEMON=$NTPD
		if [ -e '/lib/systemd/systemd-timesyncd' ]; then
			DAEMON=$TIMESYNCD
		fi
	elif [ -e '/lib/systemd/systemd-timesyncd' ]; then
		DAEMON=$TIMESYNCD
	fi
	if [[ $(check_service) == 0 ]]; then
		echo -e "${GREEN}$DAEMON is running.${NC}"
	else
		echo -e "${RED}$DAEMON is installed but inactive.${NC}"
	fi
}
	

case $1 in
	help)		usage;;
	ip)			get_ip;;
	check)		get_ntp_daemon &>/dev/null
			check_service;;
	os)			get_os_version;;
	ntp)		get_ntp_daemon;;
	-c)			CMD=$(which chronyc)
				get_ntp_daemon &>/dev/null
				if [[ $(check_service) -eq 0 ]]; then
					if [ $2 == "strat" ]; then
						$CMD tracking | grep -i "stratum" | awk -F: '{ print $2 }' | cut -d " " -f2
					elif [ $2 == "delay" ]; then
						$CMD tracking | grep -i "delay" | awk -F: '{ print $2 }' | cut -d " " -f2
					elif [ $2 == "systime" ]; then
						$CMD tracking | grep -i "system time" | awk -F: '{ print $2 }' | cut -d " " -f2
					elif [ $2 == "server" ]; then
						$CMD tracking | grep -i "reference id" | awk -F"[()]" '{ print $2 }'
					else
						usage
					fi
				fi
				;;
esac

exit 0
