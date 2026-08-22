$localFonts = @{}
Get-ChildItem "${env:LOCALAPPDATA}\Microsoft\Windows\Fonts" |
    Where-Object { $_.BaseName -like '*Nerd*' -or $_.BaseName -like '*Mono*' } |
    ForEach-Object -Process { $localFonts.Add($_.Name, $_.LastWriteTime) }

$systemFonts = @{}
Get-ChildItem "${env:windir}\Fonts" |
    Where-Object { $_.BaseName -like '*Nerd*' -or $_.BaseName -like '*Mono*' } |
    ForEach-Object -Process { $systemFonts.Add($_.Name, $_.LastWriteTime) }

$both = $systemFonts.Keys.Where({ $_ -in $localFonts.Keys }) | Sort-Object
$localOnly = $localFonts.Keys.Where({ $_ -notin $systemFonts.Keys }) | Sort-Object
$systemOnly = $systemFonts.Keys.Where({ $_ -notin $localFonts.Keys }) | Sort-Object

$localNewer = @{}
$systemNewer = @{}
$same = @{}

foreach ($font in $both) {
    if ($localFonts.$font -gt $systemFonts.$font) {
        $localNewer.Add($font, $localFonts.$font)
    } elseif ($localFonts.$font -lt $systemFonts.$font) {
        $systemNewer.Add($font, $systemFonts.$font)
    } else {
        $same.Add($font, $systemFonts.$font)
    }
}
$nl = [System.Environment]::NewLine
Write-Host "Local version is newer for following fonts:$nl$(($localNewer.Keys | Sort-Object) -join $nl)"
Write-Host "System version is newer for following fonts:$nl$(($systemNewer.Keys | Sort-Object) -join $nl)"
if ($same.Count -gt 0) {
    Write-Host "Duplicate installs detected:$nl$(($same.Keys | Sort-Object) -join $nl)"
}
