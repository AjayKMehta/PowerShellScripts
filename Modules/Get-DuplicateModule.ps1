#Requires -Module PowerShellGet

function Get-DuplicateModule {
    <#
    .SYNOPSIS
        Get the modules for which there are multiple versions installed.
    .DESCRIPTION
        Get the modules for which there are multiple versions installed.
    .PARAMETER Name
        Specifies names or name patterns of modules that this cmdlet gets.
        Wildcard characters are permitted.
    .PARAMETER AllLocations
        If set, check modules in all folders in $env:PSModulePath. Else, it only
        looks in CurrentUser and AllUsers specific folders.
    .PARAMETER ExtraInfo
        If set, results will also include Installed, Scope and InUse properties.
    .NOTES
        If you install the same version of a module with scope set to
        CurrentUser and AllUsers respectively, then Get-InstalledModule only
        shows 1 entry for the module name. Hence, Installed property may be
        unreliable in such cases.
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
    $inUseModules = Get-Module @params
    $inUse = [System.Collections.Generic.HashSet[string]]::new($inUseModules.Count)
    $inUseModules | ForEach-Object { $null = $inUse.Add((Split-Path $_.Path -Parent)) }

    function test-used($Module) {
        $path = Split-Path $Module.Path -Parent
        if ($inUse.Contains($path)) {
            $null = $inUse.Remove($path)
            return $true
        }
        return $false
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
        Where-Object Count -GT 1 |
        Select-Object -ExpandProperty Group |
        Select-Object -Property $fields
}
