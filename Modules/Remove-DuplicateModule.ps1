function Remove-DuplicateModule {
    <#
    .SYNOPSIS
        Delete (directories for) duplicate modules.
    .DESCRIPTION
        Delete (directories for) duplicate modules. Since this is a dangerous operation, it only checks CurrentUser
        and AllUsers module folders. In case of duplicate modules, it will keep the module with the highest version (lowest if KeepOld is set). If there is a tie in version, then it will keep the module in AllUsers module folder unless PreferCurrentUser is set.
    .EXAMPLE
        Remove-DuplicateModule
    .EXAMPLE
        Remove-DuplicateModule -WhatIf
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        #If true, it will keep the oldest version for a given module.
        [switch] $KeepOld,

        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [Alias('PCU')]
        #If true, it will keep the module in CurrentUser module folder in case of tie for module version.
        [switch] $PreferCurrentUser,


        #If true, will not confirm action.
        [switch] $Force
    )
    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    $dupes = Get-DuplicateModule -Verbose:$false
    if (!$dupes) {
        return
    }

    $groups = $dupes | Group-Object Name
    foreach ($group in $groups) {
        Select-Object -InputObject $group -ExpandProperty Group |
        Sort-Object @{Expression = "Version"; Descending = !$KeepOld }, @{Expression = "Path"; Descending = $PreferCurrentUser } |
        Select-Object -Skip 1 |
        ForEach-Object {
            $folder = Split-Path $_.Path -Parent
            if ($PSCmdlet.ShouldProcess($folder, "Delete directory")) {
                Remove-Item $folder -Force -Recurse -Confirm:$false -Verbose:$false -WhatIf:$false
                # Remove parent folder if empty
                $parent = Split-Path $folder -Parent
                if (!(Get-Item $parent | Get-ChildItem)) {
                    Remove-Item $parent -Force -Confirm:$false -Verbose:$false -WhatIf:$false
                }
            }
        }
    }
}