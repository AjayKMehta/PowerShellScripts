function Get-AvailableDriveLetter {
    # D and E usually correspond to DVD drives.
    Get-ChildItem function:[f-z]: -Name | Where-Object { !(Test-Path $_) }
}
