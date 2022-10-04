#!/bin/bash

base64 -d <<<"ICAgX19fX18gICAgICAgICAgICAgICAgICAgICAgICAgICAgICBfXyAgICAgICAgICAgICAgICAgICAgCiAgLyBfX18vX19fXyAgX19fX19fX19fIF9fXyAgX18gICAgICAvIC8gICBfX19fICBfX19fICBfX19fIAogIFxfXyBcLyBfXyBcLyBfX18vIF9fIGAvIC8gLyAvX19fX18vIC8gICAvIF9fIFwvIF9fIFwvIF9fIFwKIF9fXy8gLyAvXy8gLyAvICAvIC9fLyAvIC9fLyAvX19fX18vIC9fX18vIC9fLyAvIC9fLyAvIC9fLyAvCi9fX19fLyAuX19fL18vICAgXF9fLF8vXF9fLCAvICAgICAvX19fX18vXF9fX18vXF9fX18vIC5fX18vIAogICAgL18vICAgICAgICAgICAgICAgL19fX18vICAgICAgICAgICAgICAgICAgICAgICAvXy8gICAgICAK"
echo ""

if [ -z "$1" ]
then
	echo "[*] Welcome to Spray-Loop, new and improved edition!"
	echo "[*] Function : Spray-Loop runs a spraying utility of your choice (edit a oneliner into this script) and"
	echo "               waits a specified time before running it again with the next password in a list. The main"
	echo "               use case is running through a list of passwords you want to spray against a user list,"
	echo "               sleeping an hour or so between each pass through the user list to reset the lockout counter."
	echo "[*] Usage    : $0 <password list>"
exit 0
fi

COUNTER=0

for password in $(cat $1)
do
	let COUNTER++
	echo "[+] Trying guess $COUNTER: $password";
	echo "[+] "$(date)
	#trevorspray oneliner here; make sure to pass in $password
	sleep 20m
	echo "[+] 40 min till next attempt"
	sleep 20m
	echo "[+] 20 min till next attempt"
	sleep 10m
	echo "[+] 10 min till next attempt"
	sleep 5m
	echo "[+] 5 min till next attempt"
	sleep 5m
done
