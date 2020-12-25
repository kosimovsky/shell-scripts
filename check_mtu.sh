#!/bin/bash

#       script for checking MTU on linux interfaces excluding loop
#       to use it via ssh on remote host ---- ssh user@ipaddress 'bash -s' < check_mtu.sh ----
#       ./check_mtu.sh ip       ---- checks ipv4 address of the interface

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

IP=$(which ip 2>/dev/null)
if [ $? == 1 ]; then
	IP='/usr/sbin/ip'
fi

STATE=""

declare -a interfaces

interfaces=$($IP link | grep '^[0-9]' | awk -F': ' '{print $2}' | sed 's/@.*//')

for i in $interfaces; do
        echo -ne "${GREEN}$i\t${NC}"
        echo -ne "${RED}------------------------------------${NC}"
        echo -ne $($IP link show $i | grep -oP '(?<=mtu )[^ ]*')
        echo -n " "
        STATE=$($IP link show $i | grep -oP '(?<=state )[^ ]*')
        if [ ${#STATE} -eq 7 ]; then
                echo -e "${BLUE}UNKNOWN${NC}"
        else
        [ ${#STATE} -gt 2 ] && echo -e "${RED}DOWN${NC}" || echo -e "${GREEN}UP${NC}"
        fi
	case $1 in
                ip)     echo -ne "\t\t$i IPaddress is "
                        echo -e "${GREEN}$($IP -o -f inet a show $i | grep -oP '(?<=inet )[^ ]([0-9]\.*)+')${NC}\\n"
                        ;;
        esac
done

exit 0

