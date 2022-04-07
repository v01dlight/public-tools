#!/bin/bash

if [ -z "$1" ]
then
	echo "[*] Usage    : $0 <input list>"
exit 0
fi

for input in $(cat $1)
do
	echo "[+] Trying $input";
	echo "this is the part where we would execute some command on $input"
done

