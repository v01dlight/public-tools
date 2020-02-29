#!/bin/bash

if [ -z "$1" ]
then
	echo "[*] AutoPeek: a script to automate the discovery of interesting web servers"
	echo "[*] each ip in the specified range will be scanned for an open port 80, and an HTML report with screenshots for review will be generated"
	echo "[*] Usage    : $0 <ip range>"
exit 0
fi

if [ ! -d autopeek_$1 ]
then
	mkdir autopeek_$1
	mkdir autopeek_$1/images
	touch autopeek_$1/report.html
	report="autopeek_$1/report.html"
	echo $report
else
	echo "The folder autopeek_$1 already exists!"
	exit 0
fi

sudo nmap -Pn -n -p80,8080 --open $1 -oG autopeek$1/nmap-scan_$1
scan="autopeek_$1/nmap-scan_$1"
echo $scan

for ip in $(cat $scan | grep "80/" | grep -v "Nmap" | awk '{print $2}')
do
	cutycapt --url=$ip --out=autopeek_$1/images/$ip.png
done

echo "<HTML><BODY><BR>" > $report

ls -1 autopeek_$1/images/*.png | awk -F : '{print $1":\n<BR><IMG SRC=\""$1""$2"\" width=600><BR>"}' >> $report

echo "</BODY></HTML>" >> $report


