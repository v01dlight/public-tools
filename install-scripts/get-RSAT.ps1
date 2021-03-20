# Author: Gregory for Microsoft
# Source: https://community.spiceworks.com/how_to/164370-install-rsat-tools-on-windows-10-1903-via-powershell

$Install = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat*" -AND $_.State -eq "NotPresent"}

$Install | ForEach-Object {
$RSATName = $_.Name
Add-WindowsCapability -Online -Name $RsatName
}
