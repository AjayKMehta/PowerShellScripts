using namespace System.Collections.Generic
using namespace System.Management.Automation

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

        # If specified, add OutputType attribute to created function.
        [switch] $AddOutputType,

        # If set, will not use Switch parameters for Boolean properties.
        [switch] $NoSwitch,

        # If set, will set CmdletBinding for new function.
        [switch] $CmdletBinding
    )
    dynamicparam {
        if ($PSBoundParameters.ContainsKey('UseDefaultConstructor')) {
            $paramAttrib = New-ParameterAttribute -ParameterSetName 'DefaultCons' -HelpMessage 'If specified, prompt the user to select properties.'

            $dynamicParam = New-DynamicParameter -Name 'ChooseProperties' -Type ([SwitchParameter]) -Attribute $paramAttrib

            $paramDictionary = [RuntimeDefinedParameterDictionary]::new()
            $paramDictionary.Add('ChooseProperties', $dynamicParam)
            return $paramDictionary
        }
    }

    end {
        $resType = $Type.Tostring()

        if ($AddOutputType) {
            $Attribs = "`r`n    [OutputType([$restype])]"
        }
        if ($CmdletBinding) {
            $Attribs = "$Attribs`r`n    [CmdletBinding()]"
        }

        if ($PScmdlet.ParameterSetName -eq 'DefaultCons') {
            if (!$Type.GetConstructor([Type]::EmptyTypes)) {
                throw "No public default constructor exists for $_"
            }
            $properties = $Type.GetProperties().Where( { $_.SetMethod -and $_.CanWrite }) |
            Select-Object Name, PropertyType

            if ($properties) {
                $choose = $false
                if ($PSBoundParameters.TryGetValue('ChooseProperties', [ref] $choose) -and $choose) {
                    $properties = $properties | Out-GridView -PassThru -Title 'Select properties'
                    if (!$properties) {
                        throw "Operation canceled."
                    }
                }
            }

            if ($properties.Count -gt 0) {
                $params = foreach ($p in $properties) {
                    [string] $paramType = $p.PropertyType
                    $paramName = $p.Name.Substring(0, 1).ToUpper() + $p.Name.SubString(1)
                    if (!($NoSwitch) -and $p.PropertyType -eq [bool]) {
                        $paramType = 'switch'
                    }
                    "        [$paramType] `$$($paramName)"
                }
                $params = $params -join ",`r`n"

                if ($CmdletBinding) {
                    $body = @"
    # Add similar logic for optional common parameters if necessary.
    foreach (`$p in [System.Management.Automation.Cmdlet]::CommonParameters) {
        `$null = `$PSBoundParameters.Remove(`$p)
    }
    New-Object $resType -Property `$PSBoundParameters
"@
                } else {
                    $body = "    New-Object $resTy e -Property `$PSBoundParameters"
                }
            } else {
                $params = ''
                $body = "    New-Object $resType"
            }
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

            $numParams = $cons.Params.Count

            if ($numParams -gt 0) {
                $paramList = [List[string]]::new($numParams)
                $valList = [List[string]]::new($numParams)

                foreach ($p in $cons.Params) {
                    [string] $paramType = $p.ParameterType
                    $paramName = $p.Name.Substring(0, 1).ToUpper() + $p.Name.SubString(1)
                    $valList.Add("`$$ParamName")

                    [bool] $isBool = $p.ParameterType -eq [bool]
                    if (!($NoSwitch) -and $isBool) {
                        $paramType = 'switch'
                        $hasSwitch = $true
                    }
                    if (!$hasSwitch -and $p.HasDefaultValue) {
                        $defValue = $p.DefaultValue
                        if ($isBool) {
                            $defValue = if ($defValue) { '$true' } else { '$false' }
                        } elseif ($null -eq $defValue) {
                            $defValue = '$null'
                        }
                        $paramList.Add("        [$paramType] `$$($ParamName) = $defValue")
                    } else {
                        $paramList.Add("        [$paramType] `$$($ParamName)")
                    }
                }

                $params = $paramList -join ",`r`n"
                $body = "    New-Object $resType -ArgumentList $($valList -join ', ')"
            } else {
                $params = ''
                $body = "    New-Object $resType"
            }
        }

        @"
function $Name {$Attribs
    param
    (
$params
    )
$body
}
"@
    }
}