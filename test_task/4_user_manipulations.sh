#!/usr/bin/env bash

passwd user

useradd -m test
if [ $? == 0 ]; then passwd test; fi

read -p "Enter new port for ssh: " sshport
echo "Port $sshport" >> /etc/ssh/sshd_config

ufw allow $sshport/tcp

systemctl restart sshd

exit 0