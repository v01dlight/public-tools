# this lets you pass the filepath as an argument from the command line
$path = $args[0]

Import-Csv $path | Foreach-Object { 

    foreach ($property in $_.PSObject.Properties)
    {
        Write-Host $property.Value # $property.Name
    } 

}
