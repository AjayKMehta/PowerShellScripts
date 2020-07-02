function New-Wrapper {
    <#
    .SYNOPSIS
       Helps construct wrapper functions for creating .NET objects.
    .DESCRIPTION
       Helps construct wrapper functions for creating .NET objects.
    .EXAMPLE
        New-Wrapper -Type Parameter -ChooseProperties | Out-File func.ps1 -Encoding UTF8
    #>
    [CmdletBinding(DefaultParameterSetName = 'ChooseCons')]
    param
    (
        [Parameter(ParameterSetName = 'DefaultCons')]
        [switch] $UseDefaultConstructor,

        [ValidateScript(
            {
                if ($_.IsAbstract) { throw "Type cannot be abstract." }
                # $UseDefaultConstructor will only be set if it precedes this parameter!
                if ($UseDefaultConstructor -and !$_.GetConstructor([Type]::EmptyTypes)) {
                    throw "No default constructor exists for $_"
                }
            })
        ]
        [Parameter(Mandatory = $true, ParameterSetName = 'ChooseCons', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'DefaultCons', Position = 0)]
        # Type of .NET object to create.
        [Type] $Type,

        [Parameter(Mandatory = $false, Position = 1)]
        # Name of new function to create.
        [string] $Name = "New-$($Type.Name)",

        [Parameter(ParameterSetName = 'DefaultCons')]
        # If specified, prompt the user to select properties.
        [Switch] $ChooseProperties,

        # If specified, add OutputType attribute to created function.
        [switch] $AddOutputType,

        # If set, will not use Switch parameters for Boolean properties.
        [switch] $NoSwitch,

        # If set, will set PositionalBinding for new function.
        [switch] $PositionalBinding
    )

    $resType = $Type.Tostring()

    [string] $outputTypeStatement = $null
    if ($AddOutputType) {
        $outputTypeStatement = "`r`n`t[OutputType($restype)]"
    }
    if ($PScmdlet.ParameterSetName -eq 'DefaultCons') {
        $properties = $Type.GetProperties().Where( { $_.SetMethod -and $_.CanWrite }) | Select-Object Name, PropertyType

        if ($ChooseProperties) {
            $properties = $properties | Out-GridView -PassThru -Title 'Select properties'
        }

        $params = $properties.ForEach( {
                [string] $paramType = $_.PropertyType;
                if (!($NoSwitch) -and $_.propertytype -eq [bool]) {
                    $paramType = 'switch'
                }
                "        [$paramType] `$$($_.Name)"
            }) -join ",`r`n"
    } else {
        $constructors = $Type.GetConstructors()

        if ($constructors.Count -eq 0) {
            throw "$($Type.Name) has no public instance constructors"
        } elseif ($constructors.Count -eq 1) {
            $cons = $constructors[0] |
            Select-Object @{Name = 'Signature'; Expression = { $_.ToString() } },
            @{Name = 'Params'; Expression = { $_.GetParameters() } }
        } else {
            $cons = $constructors |
            Select-Object @{Name = 'Signature'; Expression = { $_.ToString() } },
            @{Name = 'Params'; Expression = { $_.GetParameters() } } |
            Out-GridView -PassThru
            if (!$cons) {
                throw "Operation canceled."
            }
        }

        $params = $cons.Params.ForEach( {
                [string] $paramType = $_.ParameterType;
                if (!($NoSwitch) -and $_.ParameterType.Name -eq 'Boolean') {
                    $paramType = 'switch'
                }
                if ($_.HasDefaultValue) {
                    "        [$paramType] `$$($_.Name) = $($_.DefaultValue)"
                } else {
                    "        [$paramType] `$$($_.Name)"
                }
            }) -join ",`r`n"
    }

    @"
function $Name {
    $outputTypeStatement
    [CmdletBinding(PositionalBinding = $PositionalBinding)]
    param
    (
$params
    )

    # Add similar logic for optional common parameters if necessary.
    foreach (`$p in [System.Management.Automation.Cmdlet]::CommonParameters) {
        `$null = `$PSBoundParameters.Remove(`$p)
    }

    New-Object $($ResType) -Property `$PSBoundParameters
}
"@
}
