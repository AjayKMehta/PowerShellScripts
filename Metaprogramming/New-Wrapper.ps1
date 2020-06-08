#TODO: Extend logic to handle non-default constructors.
function New-Wrapper {
    <#
    .SYNOPSIS
       Helps construct wrapper functions for creating .NET objects with parameter-less constructors and populating property values.
    .DESCRIPTION
       Helps construct wrapper functions for creating .NET objects with parameter-less constructors and populating property values.
    .PARAMETER Name
        Name of new function to create.
    .PARAMETER Type
        Type of .NET object to create.
    .PARAMETER Choose
        If specified, prompt the user to select properties.
    .PARAMETER AddOutputType
        If specified, add OutputType attribute to created function.
    .PARAMETER UseSwitch
        If specified, will use Switch parameters for Boolean properties.
    .EXAMPLE
        New-Wrapper -Name New-ParameterAttribute -Type Parameter -Choose -UseSwitch
    #>
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string] $Name,

        [ValidateScript( { $_.GetConstructor([Type]::EmptyTypes) })]
        [Parameter(Mandatory, Position = 1)]
        [Type] $Type,

        [Switch] $Choose,
        [switch] $OutputType,
        [switch] $UseSwitch
    )

    $resType = $Type.Tostring()

    [string] $outputTypeStatement = $null
    if ($AddOutputType) {
        $outputTypeStatement = "`r`n`t[OutputType($restype)]"
    }

    $properties = $Type.GetProperties().Where( { $_.SetMethod -and $_.CanWrite }) | Select-Object Name, PropertyType

    if ($Choose) {
        $properties = $properties | Out-GridView -PassThru -Title 'Select properties'
    }

    $params = $properties.ForEach( {
            [string] $propType = $_.PropertyType;
            if ($UseSwitch -and $_.propertytype -eq [bool])
            { $proptype = 'switch' };
            "        [$propType] `$$($_.Name)";
        }) -join ",`r`n"

    @"
function $Name {
    $outputTypeStatement
    param
    (
$params
    )

    [$($resType)] `$$ResultVarName = New-Object $($ResType) -Property `$PSBoundParameters
    `$$ResultVarName
}
"@
}
