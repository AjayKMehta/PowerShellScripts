function New-ParameterAttribute {
    <#
    .SYNOPSIS
       Returns ParameterAttribute with specified values for properties.
    .EXAMPLE
       Returns ParameterAttribute with specified values for properties.
    .EXAMPLE
        New-ParameterAttribute
    .EXAMPLE
        New-ParameterAttribute -Position 1 -ValueFromPipeline
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.parameterattribute?view=powershellsdk-7.0.0
    #>
    [OutputType([Parameter])]
    param
    (
        [switch] $Mandatory,
        [int] $Position,
        [string] $ParameterSetName = "__AllParameterSets",
        [switch] $ValueFromPipeline,
        [switch] $ValueFromPipelineByPropertyName,
        [switch] $ValueFromRemainingArguments,
        [string] $HelpMessage,
        [switch] $DontShow
    )

    New-Object Parameter -Property $PSBoundParameters
}