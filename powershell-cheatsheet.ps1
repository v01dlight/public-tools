# learn about a command, get help
get-help [cmdlet name]

# run powershell as different user (DOMAIN\eamon.mulholland for example)
Start-Process powershell -credential ""

# set a new password variable
$password= ConvertTo-SecureString -String '<NEW PASSWORD>' -AsPlainText -Force

# force password reset of a user
Set-Aduser -identity [USER NAME HERE] -ChangePasswordAtLogon $true

# get report of all hostnames
Get-ADComputer -Filter * | Select-Object -Expand Name | export-csv C:\Users\eamon.mulholland\Desktop\Scripts\AD_hosts.csv

# get report of all AD users with no employee ID
get-aduser -filter {employeeid -notlike '*'} -properties created, employeeid, employeenumber, enabled, country, city, company, office, lastlogondate, mail | Select-Object name, created, employeeid, employeenumber, enabled, country, city, company, office, lastlogondate, mail, sid | export-csv no_ID_list_[MONTH][YEAR].csv -NoTypeInformation

# get info on a user
get-aduser -properties * [USER NAME HERE]

# convert Integer8 to Date 132078640703095831 (see here for more: https://adsecurity.org/?p=378)
$Integer8 = “<NUMBER>”
[datetime]::FromFileTimeUTC($Integer8)

# spawn interactive data view GUI
Get-Process | Out-GridView

# enable default parameters for a script... put this at the top
[CmdletBinding()]

# add a directory to the path (useful for running additional tools, like nmap)
$env:Path += ";C:\Program Files\<PATH>\"

# search nmap results on windows
type .\nmap\<SCAN NAME>.gnmap | findstr "ssh"

# interact with SQL databases
Install-Module -Name SimplySql
Import-Module SimplySql
Get-Module SimplySql
Open-MySqlConnection -Server <IP> -Port 3306
