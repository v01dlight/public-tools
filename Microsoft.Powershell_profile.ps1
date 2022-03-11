Import-Module Posh-Git

Function Sync-Git {
    git pull
    git add .
    git commit -am "auto commit by Sync-Git function"
    git push
}

Set-Alias -Name gitter -Value Sync-Git
