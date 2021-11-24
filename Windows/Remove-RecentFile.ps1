using namespace System.Management.Automation

function Remove-RecentFile {
    <#
    .SYNOPSIS
        Deletes shortcuts in Recent folder based on specified criterion.
    .DESCRIPTION
        Deletes shortcuts in Recent folder. If All is set, then it will delete all shortcuts.
        If MinDate is specified, it will delete all links older than MinDate. If neither MinDate or All is specified, it will delete dead shortcuts.
    .EXAMPLE
        Remove-RecentFile -WhatIf
    .EXAMPLE
        Remove-RecentFile -WhatIf -MinDate '5/31/2020'
    #>
    [CmdletBinding(
        DefaultParameterSetName = 'Default',
        PositionalBinding = $false,
        SupportsShouldProcess = $True,
        ConfirmImpact = 'High')]
    param
    (
        [switch] $Force,

        [Parameter(ParameterSetName = 'Default')]
        #If set, delete all shortcuts.
        [switch] $All,

        [Parameter(ParameterSetName = 'Date')]
        #If MinDate is specified, it will delete all links older than MinDate.
        [datetime]$MinDate
    )

    foreach ($param in [Cmdlet]::OptionalCommonParameters) {
        $null = $PSBoundParameters.Remove($param)
    }
    foreach ($param in [Cmdlet]::CommonParameters) {
        $null = $PSBoundParameters.Remove($param)
    }

    if ($Force -and -not $Confirm) {
        $ConfirmPreference = 'None'
    }

    $shell = New-Object -Com Shell.Application
    $recent = [Environment]::GetFolderPath('Recent')

    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        $null = $PSBoundParameters.Remove('All')
        if ($All) {
            $sb = { $_.IsLink }
        } else {
            $sb = { $_.IsLink -and ([String]::IsNullOrEmpty($_.GetLink.Path) -or !(Test-Path $_.GetLink.Path)) }
        }
    } else {
        $null = $PSBoundParameters.Remove('MinDate')
        $sb = { $_.IsLink -and ($_.ModifyDate -lt $MinDate) }
    }

    $shell.Namespace($recent).Items() |
        Where-Object $sb |
        ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.Path, 'Remove shortcut')) {
                Remove-Item -LiteralPath $_.Path @PsBoundParameters;
            }
        }
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell)
}
