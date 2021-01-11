#!/usr/bin/env bash

PWD=$(pwd)

scp  $PWD/3_make_bond.sh $PWD/4_user_manipulations.sh user@192.168.2.2:/home/user

ssh -t user@192.168.2.2 'sudo /home/user/3_make_bond.sh'

ssh -t user@192.168.2.2 'sudo /home/user/4_user_manipulations.sh'

exit 0