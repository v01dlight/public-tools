#!/bin/bash

if [ -z "$1" ]
then
	base64 -d <<<"H4sIADDLWl4AA3WO0Q2AMAhE/5mCARpvAUdpcg7S4eUoqRr1Gh6Qgwb3h0j/kRxTikIRgIOsulhIxyJFc8Dn00L0fXEBIEw7OXjx1ud2ou1xjXWyEYsKmRurniAGR979lv79lJ0BE53oFAEAAA==" | gunzip
	echo ""
	echo "[*] AutoPeek : a script to automate the discovery of interesting web servers"
	echo "[*]            Each ip in the specified range will be scanned for open ports 80 and 8080."
	echo "[*]            An HTML report with screenshots will be generated for easy review."
	echo "[*] Version  : 1.0"
	echo "[*] Author   : Eamon Mulholland"
	echo "[*] GitHub   : v01dlight"
	echo "[*] Requires : nmap, cutycapt, firefox"
	echo "[*] Usage    : $0 <ip list>"
exit 0
fi

if [ -d autopeek_$1 ]
then
	echo "The folder autopeek_$1 already exists!"
	exit 0
fi

sudo nmap -Pn -n -p80,8080 --open -iL $1 -oG autopeek_nmap-scan_$1 &&

scan="autopeek_nmap-scan_$1"

mkdir autopeek_$1
mkdir autopeek_$1/images
touch autopeek_$1/report.html
mv $scan autopeek_$1/
cd autopeek_$1

report="report.html"


for ip in $(cat $scan | grep -E "\s80\/" | grep -v "Nmap" | awk '{print $2}')
do
	cutycapt --url="$ip:80" --out=images/$ip.png
done

for ip in $(cat $scan | grep -E "\s8080\/" | grep -v "Nmap" | awk '{print $2}')
do
        cutycapt --url="$ip:8080" --out=images/$ip.png
done


echo "<HTML><BODY><BR>" > $report

ls -1 images/*.png | awk -F : '{print $1":\n<BR><IMG SRC=\""$1""$2"\" width=600><BR>"}' >> $report

echo "</BODY></HTML>" >> $report

# This is a general-purpose function to ask Yes/No questions in Bash, either
# with or without a default answer. It keeps repeating the question until it
# gets a valid answer.
# author: @davejamesmiller

ask() {
    # https://djm.me/ask
    local prompt default reply

    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

# Default to No if the user presses enter without giving an answer:
if ask "Do you want to view the HTML report?" N; then
	firefox $report
else
	echo "[*] autopeek complete. Report saved in autopeek_$1/$report"
	exit 0
fi
