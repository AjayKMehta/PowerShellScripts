function Remove-DuplicateModule {
    <#
    .SYNOPSIS
        Delete (directories for) duplicate modules.
    .DESCRIPTION
        Delete (directories for) duplicate modules based on either user selection (if Choose set) or algorithm.
        In case of duplicate modules, algorithm will keep the module with the highest version (lowest if KeepOld is set). If there is a tie in version, then it will keep the module in AllUsers module folder unless PreferCurrentUser is set.
    .NOTES
        Code only checks CurrentUser and AllUsers module folders.

        After user chooses modules to delete (if Choose is set), the following checks are made:
        1. If a module selected is in use, then show an error.
        2. If all versions of a module are selected, then show an error.

        If neither 1) or 2) apply, then the selected modules will be deleted.
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

        [Parameter(Mandatory = $true, ParameterSetName = 'Choose')]
        #If set, show form with duplicate modules and allow user to choose which to delete.
        [switch] $Choose,

        #If true, will not confirm action.
        [switch] $Force
    )

    function delete-folder([string] $Folder) {
        Remove-Item $Folder -Force -Recurse -Confirm:$false -Verbose:$false -WhatIf:$false
        # Remove parent folder if empty
        $parent = Split-Path $Folder -Parent
        if (!(Get-Item $parent | Get-ChildItem)) {
            Remove-Item $parent -Force -Confirm:$false -Verbose:$false -WhatIf:$false
        }
    }

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    $dupes = Get-DuplicateModule -Verbose:$false -ExtraInfo
    if (!$dupes) {
        return
    }
    $groups = $dupes | Group-Object Name
    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        foreach ($group in $groups) {
            [int] $count = $group.Count

            $items = Select-Object -InputObject $group -ExpandProperty Group |
            Sort-Object @{Expression = "Version"; Descending = !$KeepOld }, @{Expression = "Scope"; Descending = $PreferCurrentUser }
            Write-Verbose "Keeping $($group.Name) in $($items[0].Path)"
            for ([int] $i = 1; $i -lt $count; $i++) {
                $folder = Split-Path $items[$i].Path -Parent
                if ($PSCmdlet.ShouldProcess($folder, "Delete directory")) {
                    delete-folder $folder
                }
            }
        }
    } else {
        $dupeCounts = $groups | ConvertTo-Hashtable -KeyField Name -ValueField Count

        $toDelete = $dupes | Out-GridView -Title "Select modules to delete" -PassThru
        if (!$toDelete) {
            return
        }

        # Validate selection
        $inUse = $toDelete | Where-Object InUse
        if ($inUse) {
            $message = "Cannot delete the following modules in use: {0}." -f ($inUse.Name -Join ', ')
            Write-Error $message -Category InvalidOperation
        } else {
            $deleteAll = $toDelete | Group-Object Name | Where-Object { $_.Count -eq $dupeCounts[$_.Name] }
            if ($deleteAll) {
                $message = "You must keep at least 1 version of the following modules: {0}." -f ($deleteAll.Name -Join ', ')
                Write-Error $message -Category InvalidOperation
            } else {
                foreach ($mod in $toDelete) {
                    $folder = Split-Path $mod.Path -Parent
                    if ($PSCmdlet.ShouldProcess($folder, "Delete directory")) {
                        delete-folder $folder
                    }
                }
            }
        }
    }
}
