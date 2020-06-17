#Requires -Module PowerShellGet

function Get-DuplicateModule {
    <#
    .SYNOPSIS
        Get the modules for which there are multiple versions installed.
    .DESCRIPTION
        Get the modules for which there are multiple versions installed.
    .PARAMETER Name
        Specifies names or name patterns of modules that this cmdlet gets. Wildcard characters are permitted.
    .PARAMETER AllLocations
        If set, check modules in all folders in $env:PSModulePath. Else, it only looks in Current User
        and All Users specific folders.
    .PARAMETER ExtraInfo
        If set, results will also include Installed, Scope and InUse properties.
    .OUTPUTS
        PSCustomObject[]
    .EXAMPLE
        Get-DuplicateModule
    .EXAMPLE
        Get-DuplicateModule P* -All
    .EXAMPLE
        Get-DuplicateModule -All
    #>
    param (
        [SupportsWildcards()]
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]] $Name,

        [Alias('All')]
        [switch] $AllLocations,

        [switch] $ExtraInfo
    )
    $params = $PSBoundParameters
    @('AllLocations', 'ExtraInfo').Foreach( { $null = $params.Remove($_) })
    $inUse = Get-Module @params | Select-Object Name, Version

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

    function test-ok([string] $Path) {
        $prefix = if ($PSVersionTable.PSVersion.Major -lt 6) { 'Windows' }
        $allowedPaths = "$Home\Documents\$($prefix)PowerShell\Modules", "$Env:ProgramFiles\$($prefix)PowerShell\Modules"
        $result = $false
        foreach ($modPath in $allowedPaths) {
            if ($Path.StartsWith($modPath)) {
                $result = $true
                break
            }
        }
        $result
    }

    $installed = Get-InstalledModule | Select-Object -ExpandProperty InstalledLocation
    $allUsersFolder = Split-Path $profile.AllUsersAllHosts -Parent
    $currentUserFolder = Split-Path $profile.CurrentUserAllHosts -Parent

    function get-scope([string] $Path) {
        if ($Path.StartsWith($allUsersFolder, $true, [CultureInfo]::InvariantCulture)) {
            'AllUsers'
        } elseif ($Path.StartsWith($currentUserFolder, $true, [CultureInfo]::InvariantCulture)) {
            'CurrentUser'
        } else {
            'Other'
        }
    }


    $result = Get-Module @params -ListAvailable |
    Where-Object { $AllLocations -or (test-ok $_.Path) } |
    Select-Object Name, Version, Path |
    Sort-Object Name, Version -Descending |
    Group-Object Name |
    Where-Object Count -gt 1 |
    Select-Object -ExpandProperty Group |
    Select-Object Name, Version, Path

    if ($ExtraInfo) {
        $result |
        Select-Object Name, Version, @{L = 'InUse'; E = { test-used $_ } },
        @{L = 'Installed'; E = { (Split-Path $_.Path -Parent) -in $installed } },
        @{L = 'Scope'; E = { get-scope $_.Path } }, Path
    } else {
        $result
    }
}