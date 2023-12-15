function Get-Font {
    <#
    .SYNOPSIS
        List installed fonts.
    .DESCRIPTION
        List installed fonts (system or user) based on information in registry.
    .NOTES
        Based on https://superuser.com/a/1534136/448598.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('User', 'Machine')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Type
    )
    process {
        [bool] $isUser = $Type -eq 'User'
        $drive = $isUser ? 'HKCU:' : 'HKLM:'
        Get-ItemProperty "$drive\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" |
            Get-Member -MemberType NoteProperty |
            Where-Object Name -NotIn PSChildName, PSDrive, PSParentPath, PSPath, PSProvider |
            Select-Object Name, @{
                L = 'FileName'
                E = {
                    $def = $_.Definition
                    $fileName = $def.SubString($def.IndexOf('=') + 1)
                    $isUser ? $fileName : (Join-Path 'C:\Windows\Fonts' $fileName)
                }
            }
    }
}
