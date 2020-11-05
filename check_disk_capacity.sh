#!/usr/bin/env bash

for (( i=0; i<= 9; i=i+1 )); do
	smartctl -d magaraid,$i -i /dev/sda | grep -i capacity | awk -F"[\[\]]" '{ print $2 }'
done

for (( i=0; i<14; i=i+1 )); do 
	echo -n $(smartctl -d megaraid,$i -i /dev/sda | grep -i capacity | awk -F"[\[\]]" '{ print $2 }'); 
	echo -ne ' ';  
	smartctl -d megaraid,$i -i /dev/sda | grep -i serial;  
done
