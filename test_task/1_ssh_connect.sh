#!/usr/bin/env bash

ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub user@192.168.2.2
ssh-add

ssh -t user@192.168.2.2 << EOF 
echo -n 'Hello! Now you can connect via ssh without password!'
sleep 2
EOF

bash 2_copy_script.sh

exit 0