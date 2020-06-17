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
        If set, check modules in all folders in $env:PSModulePath. Else, it only looks in CurrentUser
        and AllUsers specific folders.
    .PARAMETER ExtraInfo
        If set, results will also include Installed, Scope and InUse properties.
    .OUTPUTS
        PSCustomObject[]
    .EXAMPLE
        Get-DuplicateModule
    .EXAMPLE
        Get-DuplicateModule P* -All
    .EXAMPLE
        Get-DuplicateModule -All -ExtraInfo
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

    $allUsersFolder = Split-Path (Split-Path $profile.AllUsersAllHosts -Parent) -Parent
    $currentUserFolder = Split-Path $profile.CurrentUserAllHosts -Parent

    function test-ok([string] $Path) {
        $allowedPaths = "$allUsersFolder\Modules", "$currentUserFolder\Modules"
        $result = $false
        foreach ($modPath in $allowedPaths) {
            if ($Path.StartsWith($modPath, $true, [CultureInfo]::InvariantCulture)) {
                $result = $true
                break
            }
        }
        $result
    }

    function get-scope([string] $Path) {
        if ($Path.StartsWith($allUsersFolder, $true, [CultureInfo]::InvariantCulture)) {
            'AllUsers'
        } elseif ($Path.StartsWith($currentUserFolder, $true, [CultureInfo]::InvariantCulture)) {
            'CurrentUser'
        } else {
            'Other'
        }
    }

    if ($ExtraInfo) {
        $installed = Get-InstalledModule | Select-Object -ExpandProperty InstalledLocation

        $fields = 'Name', 'Version', @{L = 'InUse'; E = { test-used $_ } },
        @{L = 'Installed'; E = { (Split-Path $_.Path -Parent) -in $installed } },
        @{L = 'Scope'; E = { get-scope $_.Path } }, 'Path'
    } else {
        $fields = 'Name', 'Version', 'Path'
    }

    Get-Module @params -ListAvailable |
    Where-Object { $AllLocations -or (test-ok $_.Path) } |
    Select-Object Name, Version, Path |
    Sort-Object Name, Version -Descending |
    Group-Object Name |
    Where-Object Count -gt 1 |
    Select-Object -ExpandProperty Group |
    Select-Object -Property $fields
}