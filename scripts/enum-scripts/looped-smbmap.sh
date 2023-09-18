#!/bin/bash

if [ -z "$1" ]
then
	echo "[*] Usage    : $0 <input list>"
exit 0
fi

for ip in $(cat $1)
do
	echo "[+] Trying $ip";
	smbmap -v -H $ip
	sleep .5s
done

