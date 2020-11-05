#!/usr/bin/env bash

#       script for checking MTU on linux interfaces excluding loop
#	to use it via ssh on remote host ---- ssh user@ipaddress 'bash -s' < check_mtu.sh ----

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

declare -a interfaces

interfaces=$( ip link | grep '^[0-9]' | awk -F': ' '{print $2}' | sed 's/@.*//')

for i in $interfaces; do
        echo -ne "${GREEN}$i\t${NC}"
        echo -ne "${RED}------------------------------------${NC}"
        ip link show $i | grep -oP '(?<=mtu )[^ ]*'
done

exit 0

~
