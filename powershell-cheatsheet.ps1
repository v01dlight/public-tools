# learn about a command, get help
get-help [cmdlet name]

# run powershell as different user (DOMAIN\user for example)
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

# search all files in a directory for a set of strings and return the filepath and full line where any are found
Get-ChildItem -Path . -File | Select-String -Pattern "MY_STRING", "MY_STRING_2" -List | ForEach-Object { "$($_.Path): $($_.Line)" }
# if you just want the line and not the filepath
Get-ChildItem -Path . -File | Select-String -Pattern "MY_STRING", "MY_STRING_2" -List | ForEach-Object { "$($_.Line)" }

## Add multiple Users to an AD group
```powershell
# by name
Add-ADGroupMember -Identity "MY_GROUP" -Members user1, user2, user3

# with a filter:
Get-ADUser -Filter "title -eq 'account manager'" | ForEach-Object { Add-ADGroupMember -Identity "MY_GROUP" -Members $_ }
```

## get some details about a list of users
```powershell
user1, user2, user3 | ForEach-Object { Get-AdUser -Identity $_  -properties memberof}
```

## Check if a given list of users are in a given list of groups
```powershell
$users = "TestUsername1", "TestUsername2", "TestUsername3"
$groups = "Group 1", "Group 2"

foreach ($group in $groups) {
    $members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty SamAccountName

    foreach ($user in $users) {
        If ($members -contains $user) {
            # Write-Host "$user is a member of $group"
        } Else {
            Write-Host "$user is not a member of $group"
        }
    }
}
```

## Add one or more users to a list of groups and add the ticket number to the notes
```powershell
$users = "USER1", "USER2", "USER3"
$groups = "GROUP1", "GROUP2", "GROUP3"

foreach ($group in $groups) {
  Add-ADGroupMember -Identity $group -Members $users
  $group = Get-AdGroup $group -Properties info
  $notes = $group.info
  $notes += "RITM_NUM_HERE; "
  Set-AdGroup $group -Replace @{info = $notes}
}

# to check your work (i.e. see if those users are now members of those groups and view the updated notes field)
foreach ($group in $groups) {
  $members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty SamAccountName

  foreach ($user in $users) {
    If ($members -contains $user) {
      Write-Host "$user is a member of $group"
      Get-AdGroup $group -Properties info | select-object samaccountname, info | fl
    } Else {
        Write-Host "Check your work! $user is not a member of $group"
    }
  }
}
```
