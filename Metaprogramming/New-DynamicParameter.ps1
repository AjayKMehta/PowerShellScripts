using namespace System.Management.Automation

Function New-DynamicParameter {
    <#
    .SYNOPSIS
        Helper function for creating dynamic parameters.
    .DESCRIPTION
        Helper function for creating dynamic parameters.
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param (
        # Name of the dynamic parameter
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Name,

        # Type for the dynamic parameter.
        [Parameter(Mandatory = $true, Position = 1)]
        [System.Type] $Type,

        [Attribute[]] $Attribute
    )

    $AttributeCollection = [Collections.ObjectModel.Collection[System.Attribute]]::new()
    foreach ($attrib in $Attribute) {
        $AttributeCollection.Add($attrib)
    }

    [RuntimeDefinedParameter]::new($Name, $Type, $AttributeCollection)
}
