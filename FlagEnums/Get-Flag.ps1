function Get-Flag {
    <#
    .SYNOPSIS
        Returns all bit fields that are set for EnumValue.
    .DESCRIPTION
        Returns all bit fields that are set for EnumValue.
    .PARAMETER EnumValue
        The value for which you want to check bit fields. Type must be of flag enum or error will occur.
    .PARAMETER ShowAll
        If specified, will check all possible values of enum to see if set.
        This may result in superfluous values if the enum has compound values defined (combination of 2 or more enum values).
    .PARAMETER ExcludeCompound
        If specified, compound values are excluded from the return value. Only applies when ShowAll is specified.
    .EXAMPLE
        [System.Security.AccessControl.FileSystemRights]$fsr = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Synchronize,Modify"
        Get-Flag $fsr
    .EXAMPLE
        Get-Flag ([System.Security.AccessControl.FileSystemRights]::FullControl) -ShowAll
    .EXAMPLE
        [System.Text.RegularExpressions.RegexOptions]::None | Get-Flag
    .EXAMPLE
        Get-Flag ([System.Security.AccessControl.FileSystemRights]"Write") -ShowAll -ExcludeCompound
    .EXAMPLE
        ([System.Security.AccessControl.FileSystemRights]"Traverse"),[System.Security.AccessControl.FileSystemRights]::FullControl  | Get-Flag
    #>
    param
    (
        [ValidateScript( { Test-FlagEnum ($_.GetType()) })]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        $EnumValue,
        [switch] $ShowAll,
        [switch] $ExcludeCompound
    )
    begin {
        # Compound values are not 2^n.
        $filter = { $_ -ne 0 -and $EnumValue.HasFlag($_) -and (!$ExcludeCompound -or (Test-Integer ([Math]::Log($_, 2)))) }
    }

    process {
        [Type] $enumType = $EnumValue.GetType()

        if ($EnumValue -eq 0) {
            $EnumValue
        } else {
            $values = $enumType.GetEnumValues() | Select-Object -Unique
            if ($ShowAll) {
                $result = $values | Where-Object $filter
            } else {
                $result = @()
                [int] $check = [int] $EnumValue
                $eValue = $EnumValue
                $values = $values | Sort-Object -Descending
                foreach ($value in $values) {
                    if ($eValue -eq $value -or $eValue.HasFlag($value)) {
                        $result += $value
                        $check -= [int] $value
                        if ($check -eq 0) {
                            break
                        }
                        $eValue = [Enum]::ToObject($enumType, $check)
                    }
                }
            }
            $result
        }
    }
}