function Remove-RecentFile {
    <#
    .SYNOPSIS
        Deletes all dead shortcuts in Recent folder.
    .DESCRIPTION
        Deletes all dead shortcuts in Recent folder.
    .EXAMPLE
        Remove-RecentFile -Force
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    param
    (
        [switch] $Force
    )

    $PSBoundParameters["Confirm"] = $false
    $PSBoundParameters["WhatIf"] = $false
    $PSBoundParameters["Verbose"] = $false

    $shell = New-Object -Com Shell.Application
    $recent = [Environment]::GetFolderPath("Recent")

    $shell.Namespace($recent).Items() |
    Where-Object { $_.IsLink -and ([String]::IsNullOrEmpty($_.GetLink.Path) -or !(Test-Path $_.GetLink.Path)) } |
    ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.Path, "Remove dead shortcut")) {
            Remove-Item -LiteralPath $_.Path @PsBoundParameters;
        }
    }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell)
}
