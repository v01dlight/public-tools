
# learn about a command, get help
get-help [cmdlet name]

# run powershell as different user (DOMAIN\eamon.mulholland for example)
Start-Process powershell -credential ""

# set a new password variable
$password= ConvertTo-SecureString -String '[NEW PASSWORD HERE]' -AsPlainText -Force

# force password reset of a user
Set-Aduser -identity [USER NAME HERE] -ChangePasswordAtLogon $true

# get report of all hostnames
Get-ADComputer -Filter * | Select-Object -Expand Name | export-csv C:\Users\eamon.mulholland\Desktop\Scripts\AD_hosts.csv

# get report of all AD users with no employee ID
get-aduser -filter {employeeid -notlike '*'} -properties created, employeeid, employeenumber, enabled, country, city, company, office, lastlogondate, mail | Select-Object name, created, employeeid, employeenumber, enabled, country, city, company, office, lastlogondate, mail, sid | export-csv no_ID_list_[MONTH][YEAR].csv -NoTypeInformation

# get info on a user
get-aduser -properties * [USER NAME HERE]

# convert Integer8 to Date 132078640703095831 (see here for more: https://adsecurity.org/?p=378)
$Integer8 = “[NUMBER GOES HERE]”
[datetime]::FromFileTimeUTC($Integer8)

# spawn interactive data view GUI
Get-Process | Out-GridView

# enable default parameters for a script... put this at the top
[CmdletBinding()]