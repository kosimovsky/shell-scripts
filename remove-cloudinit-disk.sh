#!/usr/bin/env bash

set -e
# set -x

function usage() {
    printf "%s\n" "${blue}$0 --all${normal} --------------------------- To remove cloudinit disks from all vm in cluster"
    printf "%s\n" "${blue}$0 --host${normal} -------------------------- To remove cloudinit disks from all vm on $(hostname)"
    printf "%s\n" "${blue}$0 -1 <absolute-path-to-vm-conf>${normal} --- To remove cloudinit disk of specific vm"
}

red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
normal=$(tput sgr0)


declare -a configs

function get_cluster_configs() {
    configs=$(find /etc/pve/nodes/*/qemu-server/ -name '*.conf')
}

function get_host_configs() {
    configs=$(find /etc/pve/qemu-server/ -name '*.conf')
}

# проверка на темплейт, чтоб не удалить его диск клауд инит 
function is_template() {
    if [[ ! -z $(grep "template: 1" $1) ]]; then
        echo 0
    else
        echo 1
    fi
}

# выцепить из конфига название пула, на котором лежит диск cloudinit
function pool_name_from_config() {
    grep -oP '(?<=ide[0-9]: ).+(?=:)' $1    
}

function cloudinit_disk_name() {
    grep -oP '[a-z0-9-]+cloudinit' $1
}

function clear_from_config() {
    sed -i -E '/(.*)cloudinit,media(.*)/d' $1
}

function remove() {
    if [[ $(is_template $1) == 1 ]]; then
        local pool=$(pool_name_from_config $1)
        local disk=$(cloudinit_disk_name $1)
        if [[ ! $disk ]]; then
            printf "%s\n" "${red}There is no cloudinit disk in $1${normal}" 1>&2
            return 1
        else
            clear_from_config $1
            rados -p $pool rm rbd_id.$disk
            printf "%s\n" "${green}$disk has been deleted from $pool${normal}"
            sleep 1
        fi
    else
        printf "%s\n%s\n" "${red}$1 is template" "${blue}skipping....${normal}"
        return 1
    fi
}

function loop_all() {
    get_cluster_configs
    for c in $configs; do
        remove $c || continue
    done 
}

function loop_host() {
    get_host_configs
    for c in $configs; do
        remove $c || continue
    done
}

function single_vm() {
    if test -f $1; then
        remove $1
    else
        printf "%s\n" "${red}Error! $1 does not exists. It need to pass absolute path of file${normal}"
    fi
}

case $1 in
    help)       usage;;
    --all)      loop_all;;
    --host)     loop_host;;
    -1)         single_vm $2;;
    *)          usage;;
esac
exit 0
