alias la='ls --color=always -hla'

alias grok-lair='ngrok http --host-header=lair.localhost https://lair.localhost:443'

# connect to Hack the Box
alias htb='sudo openvpn ~/HTB/lab_Voidlight.ovpn'

# query the cheatsheet; remember some entries may need a manual search since -A 1 only helps for one liners and some commands in the cheatsheet have more
cheatsheet(){
	grep -A 1 "$@" ~/public-tools/cheatsheet.txt
}

# fully updates the system, removed unneeded packages, and then reboots
function apt-updater {
	sudo apt update &&
	echo "[+] Starting 'apt full-upgrade' now..."
	sudo apt full-upgrade -Vy &&
	echo "[+] ...done! Doing some cleanup..."
	sudo apt autoremove -y &&
	sudo apt autoclean &&
	sudo apt clean &&
	echo "[+] ...done! Now it's time to reboot. System will auto reboot in 5 minutes. CTRL + C to cancel."
	sleep 5m &&
	sudo reboot
}

# syncs current github repo
function gitter {
	git pull
	git add .
	git commit -am "auto commit by gitter function"
	git push
}

# pulls all screenshots (and other pics) to local folder
function grab-screenshots {
	mv -v ~/Pictures/* .
}

# find random webservers to connect to
function webroulette {
	nmap -Pn -sS -p 80 -iR 0 --open
}
