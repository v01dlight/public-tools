alias la='ls --color=always -hla'

# connect to Hack the Box
alias htb='sudo openvpn ~/HTB/lab_Voidlight.ovpn'

# query the cheatsheet; remember some entries may need a manual search since -A 1 only helps for one liners and some commands in the cheatsheet have more
cheatsheet(){
        grep -A 1 "$@" ~/public-tools/cheatsheet.txt
}

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
