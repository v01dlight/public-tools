<#
.SYNOPSIS
  Infinite stream of dotted lines with bouncing symbols, each symbol in a random color.

.PARAMETER LineLength
  Number of characters per printed line (default 100).

.PARAMETER Speed
  Delay between frames in milliseconds (default 80).

#>

param(
    [int]$LineLength = 100,
    [int]$Speed = 80
)

# Symbols to animate
$Symbols = @("*","&","%","#","+")

# Valid console colors (System.ConsoleColor names)
$ValidColors = @(
    "Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow",
    "Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White"
)

# Choose random colors for symbols. Try to pick unique colors when possible.
if ($ValidColors.Count -ge $Symbols.Count) {
    # pick unique colors
    $Picked = Get-Random -InputObject $ValidColors -Count $Symbols.Count
} else {
    # not enough unique colors, pick with replacement
    $Picked = for ($i=0; $i -lt $Symbols.Count; $i++) { Get-Random -InputObject $ValidColors }
}

# Build mapping symbol -> color (keys are strings)
$SymbolColors = @{}
for ($i = 0; $i -lt $Symbols.Count; $i++) {
    $key = [string]$Symbols[$i]
    $SymbolColors[$key] = $Picked[$i]
}

# Initialize symbol states
$State = foreach ($s in $Symbols) {
    [PSCustomObject]@{
        Symbol = [string]$s
        Pos    = Get-Random -Minimum 0 -Maximum $LineLength
        Dir    = if ((Get-Random) % 2 -eq 0) { 1 } else { -1 }
        Step   = Get-Random -Minimum 1 -Maximum 4
        Color  = $SymbolColors[[string]$s]
    }
}

# Main loop: print lines forever
while ($true) {

    # Build a blank line as char array
    $Chars = ("." * $LineLength).ToCharArray()

    # Place each symbol into the char array and update its state
    foreach ($obj in $State) {

        # Place symbol if within bounds
        if ($obj.Pos -ge 0 -and $obj.Pos -lt $LineLength) {
            $Chars[$obj.Pos] = [char]$obj.Symbol
        }

        # Move symbol
        $obj.Pos += $obj.Dir * $obj.Step

        # Bounce at edges and randomize step on bounce
        if ($obj.Pos -ge $LineLength) {
            $obj.Pos = $LineLength - 1
            $obj.Dir = -1
            $obj.Step = Get-Random -Minimum 1 -Maximum 4

            # Optionally re-randomize color on bounce (uncomment to enable)
            # $obj.Color = Get-Random -InputObject $ValidColors
            # $SymbolColors[[string]$obj.Symbol] = $obj.Color
        }
        elseif ($obj.Pos -lt 0) {
            $obj.Pos = 0
            $obj.Dir = 1
            $obj.Step = Get-Random -Minimum 1 -Maximum 4

            # Optionally re-randomize color on bounce (uncomment to enable)
            # $obj.Color = Get-Random -InputObject $ValidColors
            # $SymbolColors[[string]$obj.Symbol] = $obj.Color
        }
    }

    # Print the line with colors, only passing -ForegroundColor when a valid color exists
    for ($i = 0; $i -lt $Chars.Count; $i++) {
        $char = [string]$Chars[$i]

        if ($SymbolColors.ContainsKey($char) -and $SymbolColors[$char]) {
            # Valid color exists for this character
            Write-Host $char -NoNewline -ForegroundColor $SymbolColors[$char]
        }
        else {
            # Regular dot or other char: print without ForegroundColor
            Write-Host $char -NoNewline
        }
    }

    Write-Host ""  # newline

    Start-Sleep -Milliseconds $Speed
}
