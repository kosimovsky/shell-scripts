#!/usr/bin/env bash

#set -x

declare -a MACHINES

MACHINES=$(virsh list --all | tail -n +3 | sed '/^$/d' | awk '{ print $2 }')


get_disks ()
{
    declare -a disks
    disks=$(virsh domblklist --domain $1 | tail -n +3 | sed '/^$/d' | awk '{ print $1 }')
    for i in $disks; do
        virsh domblkinfo --domain $1 --device $i &>/dev/null
        if [ $? == 0 ]; then
            virsh domblkinfo --domain $1 --device $i --human | grep -iw 'capacity' | awk '{ printf "%4d %-4s | ", $2, $3 }'
        else
            continue
        fi
    done
    echo
}

get_cpu ()
{
    CPU=$(virsh dominfo $1 | awk '/CPU\(s\)/{print $2}')
    printf "%-2s| " "$CPU"
}

get_ram ()
{
    RAM=$(virsh dominfo $1 | awk '/Max\ memory/{print $3$4}' | sed 's/B//' | numfmt --from iec-i --to iec)
    printf "%-5s| " "$RAM"
}

get_ip_from_mac () {
    for m in $MACHINES; do
        MAC=''
        IP=''
        get_vm_mac=$(virsh domiflist --domain $m | grep -io '[0-9a-f:]\{17\}' | wc -l)
        if [ get_vm_mac == 1 ]; then
            MAC=$(virsh domiflist --domain $m | grep -io '[0-9a-f:]\{17\}')
            IP=$(arp -en | grep -s $(virsh domiflist --domain $m | grep -io -s '[0-9a-f:]\{17\}') | awk '{ print $1 }')
            printf "%-25s| %-17s| " "$m" "$IP"
            get_ram $m
            get_cpu $m
            get_disks $m
        elif [ get_vm_mac > 1 ]; then
            declare -a macs
            macs=$(virsh domiflist --domain $m | grep -io -s '[0-9a-f:]\{17\}')
            for i in $macs; do
                arp -an | grep -s $i &>/dev/null
                if [ $? == 0 ]; then
                    MAC=$i
                else
                    continue
                fi
            done
            IP=$(arp -en | grep -s $MAC 2>/dev/null | awk '{ print $1 }')
            printf "%-25s| %-17s| " "$m" "$IP"
            get_ram $m
            get_cpu $m
            get_disks $m
        fi
    done
}

get_ip_from_mac
exit 0
