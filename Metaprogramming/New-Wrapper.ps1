function New-Wrapper {
    <#
    .SYNOPSIS
       Helps construct wrapper functions for creating instances of .NET and PowerShell classes.
    .DESCRIPTION
       Helps construct wrapper functions for creating instances of .NET and PowerShell classes
    .EXAMPLE
        New-Wrapper -Type [Parameter] -Choose | Out-File func.ps1 -Encoding UTF8
    .EXAMPLE
     class Test {
        [int] $X
        [string] $Y
    }

    New-Wrapper -Type ([Test]) -Choose -UseDefaultConstructor

    # OUTPUT

    # function New-Test {
    #     param
    #     (
    #         [int] $X,
    #         [string] $Y
    #     )

    #     New-Object Test -Property $PSBoundParameters
    # }

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
                return $true
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

        # If set, will set CmdletBinding for new function.
        [switch] $CmdletBinding
    )

    $resType = $Type.Tostring()

    if ($AddOutputType) {
        $Attribs = "`r`n    [OutputType([$restype])]"
    }
    if ($CmdletBinding) {
        $Attribs = "$Attribs`r`n    [CmdletBinding()]"
    }

    if ($PScmdlet.ParameterSetName -eq 'DefaultCons') {
        $properties = $Type.GetProperties().Where( { $_.SetMethod -and $_.CanWrite }) | Select-Object Name, PropertyType

        if ($ChooseProperties) {
            $properties = $properties | Out-GridView -PassThru -Title 'Select properties'
            if (!$properties) {
                throw "Operation canceled."
            }
        }

        $params = $properties.ForEach( {
                [string] $paramType = $_.PropertyType
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
                [string] $paramType = $_.ParameterType
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
function $Name {$Attribs
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
