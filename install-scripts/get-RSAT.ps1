$Install = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat*" -AND $_.State -eq "NotPresent"}

$Install | ForEach-Object {
$RSATName = $_.Name
Add-WindowsCapability -Online -Name $RsatName
}
