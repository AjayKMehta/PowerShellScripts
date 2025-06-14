function Get-AvailableDriveLetter {
    Get-ChildItem function:[a-z]: -Name | Where-Object { !(Test-Path $_) }
}
