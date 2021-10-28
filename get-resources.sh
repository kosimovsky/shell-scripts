#!/bin/bash

# запустить можно локально или ssh user@server 'bash -s' < get_resourses.sh

#set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

IP=$(which ip 2>/dev/null)

if [ $? == 1 ]; then
	IP='/usr/sbin/ip'
fi

get_CPU ()
{
    echo -ne "CPU -------- "
    lscpu | grep '^CPU(' | awk -F: '{ print $2 }' | tr -d ' '
}

get_RAM ()
{
    echo -ne "RAM -------- "
    free -mh | grep Mem | awk -F: '{ print $2 }' | awk -F ' ' '{ print $1 }' | tr -d ' '
}

get_disk ()
{
    lsblk | grep -P '^sd([a-z]?)' | awk -F ' ' '{ print $1 " -------- " $4 }'
}

get_ip ()
{
    $IP -o -f inet a  | grep -oP '(?<=inet )[^ ]([0-9]\.*)+' | grep ^10     # без последнего grep вернет ip всех ipv4 интерфейсов в статусе UP
}

echo -ne "${GREEN}$(hostname -f)${NC}  "
get_ip
get_CPU
get_RAM
get_disk

echo -e "\\n"

exit 0

# vim:ft=sh
