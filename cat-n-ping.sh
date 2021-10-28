#!/usr/bin/env bash

FILE=$1

grep -w 'ansible_host' $FILE | grep -v '#' | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' > ips

while read ip in hosts; do fping $ip; done < ips
