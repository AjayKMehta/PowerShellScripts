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

            Test([int] $x, [string] $y) {
                $this.X = $x
                $this.Y = $y
            }
        }

        New-Wrapper -Type ([Test]) -UseDefaultConstructor -Name Get-Test

        # OUTPUT

        # function Get-Test {
        #     param
        #     (
        #         [int] $X,
        #         [string] $Y
        #     )

        #     New-Object Test -Property $PSBoundParameters
        # }
    .EXAMPLE
        $typeDef = @"
        using System;
        using System.Collections.Generic;

        namespace Test
        {
            public class Foo
            {
                public Foo(int num = 0 , bool isValid = true, IEnumerable<string> items = null)
                {
                    this.Number = num;
                    this.IsValid = isValid;
                    if (items != null)
                    {
                        this.Items.AddRange(items);
                    }
                }

                public Foo(int num, bool isValid) : this(num, isValid, null)
                {
                }

                public Foo(int num = 0) : this(num, true, null)
                {
                }

                public int Number { get; }
                public bool IsValid { get; }
                public List<string> Items { get; }
            }
        }
        "@

        Add-Type -TypeDefinition $typeDef -Language CSharp

        New-Wrapper ([Test.Foo]) -NoSwitch
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
    function construct-param {
        param (
            [Type] $ParamType,
            [string] $ParamName,
            [bool] $HasDefaultValue = $false,
            [object] $DefaultValue
        )

        [string] $paramType = $ParamType
        $ParamName = $ParamName.Substring(0, 1).ToUpper() + $ParamName.SubString(1)

        [bool] $isBool = $ParamType -eq [bool]
        [bool] $hasSwitch = $false
        if (!($NoSwitch) -and $isBool) {
            $paramType = 'switch'
            $hasSwitch = $true
        }
        if (!$hasSwitch -and $HasDefaultValue) {
            $defValue = $($DefaultValue)
            if ($isBool) {
                $defValue = if ($defValue) { '$true' } else { '$false' }
            } elseif ($null -eq $defValue) {
                $defValue = '$null'
            }
            "        [$paramType] `$$($ParamName) = $defValue"
        } else {
            "        [$paramType] `$$($ParamName)"
        }
    }

    if ($PScmdlet.ParameterSetName -eq 'DefaultCons') {
        $properties = $Type.GetProperties().Where( { $_.SetMethod -and $_.CanWrite }) | Select-Object Name, PropertyType

        if ($ChooseProperties -and $properties) {
            $properties = $properties | Out-GridView -PassThru -Title 'Select properties'
            if (!$properties) {
                throw "Operation canceled."
            }
        }

        $params = $properties.ForEach( {
                construct-param $_.PropertyType $_.Name
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
                construct-param $_.ParameterType $_.Name $_.HasDefaultValue $_.DefaultValue
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
