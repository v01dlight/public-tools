#!/bin/bash
# This script will watch a file and then kill a process (python3 running a webserver in this case)
# once the file gets to a given size. This is to allow collecting samples of specified sizes,
# and prevent logs taking up too much disk space.

file="log.txt"
maxsize=500000    # 500000 kilobytes, 0.5 gigabytes

while true; do
    actualsize=$(du -k "$file" | cut -f1)
    if [ $actualsize -ge $maxsize ]; then
        echo "[!] size is over $maxsize kb"
        echo "[!] Killing server..."
	pkill -f python3
        exit
    # else
        # echo "[+] size is under $maxsize kb"
    fi

    sleep 5 # in seconds = 30 minutes
done
