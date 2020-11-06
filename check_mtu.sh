#!/bin/bash

#       script for checking MTU on linux interfaces excluding loop
#       to use it via ssh on remote host ---- ssh user@ipaddress 'bash -s' < check_mtu.sh ----

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
IP=$(which ip)
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
done

exit 0

