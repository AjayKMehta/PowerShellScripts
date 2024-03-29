using namespace System.Collections

function Get-Flag {
    <#
    .SYNOPSIS
        Returns all bit fields that are set for input enum value.
    .DESCRIPTION
        Returns all bit fields that are set for input enum value.
    .PARAMETER EnumValue
        The value for which you wish to check bit fields.
        Type must be a flag enum (enum that has FlagsAttribute marked) or error will occur.
    .PARAMETER Show
        This can take one of 3 values: All, Compound or NoCompound.
        If All, it will check all possible values of enum to see if they are set.
        This may result in superfluous values if the enum has compound values defined
        (Compound value is a combination of 2 or more enum values).

        If Compound is specified, compound values are NOT broken into their constituent values.

        If NoCompound is specified, compound values are excluded from the return value.
    .EXAMPLE
        ([System.Security.AccessControl.FileSystemRights]'Traverse'),
        [System.Security.AccessControl.FileSystemRights]::FullControl  | Get-Flag
    .EXAMPLE
        [Flags()]
        enum MyEnum {
            None = 0
            One = 1
            Two = 2
            Both  = 3
        }

        $x = [MyEnum]::Both
        Get-Flag $x
        Get-Flag $x -Show 'NoCompound'
        Get-Flag $x -Show 'All'
    .EXAMPLE
        [Flags()]
        enum MyEnum2 {
            None = 0
            One = 1
            Uno = 1
            Two = 2
            Both = 3
        }

        $y = [MyEnum2]::Both
        Get-Flag $y
        Get-Flag $y -Show 'NoCompound'
        Get-Flag $y -Show 'All'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    param
    (
        [ValidateScript( { Test-FlagEnum ($_.GetType()) })]
        [Parameter(Mandatory = $true, ParameterSetName = 'Default', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Pipeline', ValueFromPipeline = $true)]
        $EnumValue,

        [ValidateSet('All', 'Compound', 'NoCompound')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Default', Position = 1)]
        [Parameter(Mandatory = $false, ParameterSetName = 'Pipeline', Position = 0)]
        [string] $Show = 'Compound'
    )
    process {
        [Type] $enumType = $EnumValue.GetType()
        # When there are 2 enum fields having same numeric value, you get duplicates!
        # For example, WriteData and CreateFiles for FileSystemRights.
        $values = $enumType.GetEnumValues() | Sort-Object -Descending -Unique

        if ($EnumValue -eq 0) {
            if ($values[-1] -eq 0) {
                $result = [ArrayList]::new(1)
                $result.Add($EnumValue)
            }
        } else {
            [bool] $all = $Show -eq 'All'
            [bool] $noCompound = $Show -eq 'NoCompound'

            [int] $check = [int] $EnumValue
            $eValue = $EnumValue
            $result = [ArrayList]::new($values.Count)
            foreach ($value in $values) {
                [int] $val = [int] $value
                if ($noCompound -and !(Test-Integer ([Math]::Log($val, 2)))) {
                    continue;
                }
                if ($eValue.HasFlag($value)) {
                    $null = $result.Add($value)
                    if (!$all) {
                        $check -= $val
                        if ($check -eq 0) {
                            break
                        }
                        $eValue = [Enum]::ToObject($enumType, $check)
                    }
                }
            }
            , $result
        }
    }
}
