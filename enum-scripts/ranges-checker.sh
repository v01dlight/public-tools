#!/bin/bash

if [ -z "$1" ]; then
	echo "This script will ping sweep a bunch of IP ranges or subnets and tell you which ones have reachable hosts, and how many."
	echo "[*] Usage    : $0 <input file>"
exit 0
fi

counter=0

for range in $(cat $1)
do
	((counter++))

	#echo "[+] Trying $range";
	nmap -sn $range -oA ping-sweep_$counter > /dev/null
	num_hosts=$(grep "Up" ping-sweep_$counter.gnmap | wc -l)

	if [ $num_hosts -gt 0 ]; then
		echo "[+] There are $num_hosts reachable hosts (which respond to ping) in $range"
	elif [ $num_hosts -eq 0 ]; then
		echo "[-] No hosts in $range are reachable!"
	else
		echo "[!] ERROR: num_hosts not >= 0"
	fi
done
