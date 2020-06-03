function Get-DuplicateModule {
    <#
    .SYNOPSIS
        Get the modules for which there are multiple versions installed.
    .DESCRIPTION
        Get the modules for which there are multiple versions installed.
    .PARAMETER AllLocations
        If set, check modules in all folders in $env:PSModulePath. Else, it only looks in Current User
        and All Users specific folders.
    .EXAMPLE
        Get-DuplicateModule
    .EXAMPLE
        Get-DuplicateModule -All
    #>
    param (
        [Alias('All')]
        [switch] $AllLocations
    )

    $inUse = Get-Module | Select-Object Name, Version

    filter test-used($Module) {
        foreach ($inUseModule in $inUse) {
            $result = $false
            if ($Module.Name -eq $inUseModule.Name -and $Module.Version -eq $inUseModule.Version) {
                $result = $true
                break
            }
        }
        $result
    }

    $prefix = if ($PSVersionTable.PSVersion.Major -lt 6) { 'Windows' }
    $allowedPaths = "$Home\Documents\$($prefix)PowerShell\Modules", "$Env:ProgramFiles\$($prefix)PowerShell\Modules"

    function test-ok([string] $Path) {
        $result = $false
        foreach ($modPath in $allowedPaths) {
            if ($Path.StartsWith($modPath)) {
                $result = $true
                break
            }
        }
        $result
    }

    Get-Module -ListAvailable |
    Where-Object {$AllLocations -or (test-ok $_.Path)} |
    Select-Object Name, Version, Path |
    Sort-Object Name, Version -Descending |
    Group-Object Name |
    Where-Object Count -gt 1 |
    Select-Object -ExpandProperty Group |
    Select-Object Name, Version, @{L = 'InUse'; E = { test-used $_ } }, Path
}