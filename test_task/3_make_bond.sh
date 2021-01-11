#!/usr/bin/env bash

cat << EOF > /etc/network/interfaces.d/bond0
auto bond0
iface bond0 inet static
address 192.168.2.2
netmask 255.255.252.0
slaves ens18 ens19
bond-mode 802.3ad
bond-miimon 100
EOF

systemctl restart networking.service
ifup bond0

exit 0