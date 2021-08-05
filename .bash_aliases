alias la='ls --color=always -hla'

alias htb='openvpn ~/HTB/Voidlight.ovpn'

# fully updates the system, removed unneeded packages, and then reboots
function apt-updater {
	sudo apt update &&
	sudo apt dist-upgrade -Vy &&
	sudo apt autoremove -y &&
	sudo apt autoclean &&
	sudo apt clean &&
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
