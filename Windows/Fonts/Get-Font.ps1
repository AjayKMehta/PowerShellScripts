function Get-Font {
    <#
    .SYNOPSIS
        List installed fonts.
    .DESCRIPTION
        List installed fonts (system or user) based on information in registry.
    .EXAMPLE
        Get-Font -Type Machine -Name *Nerd* | Select-Object -First 3
    .NOTES
        Based on https://superuser.com/a/1534136/448598.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('User', 'Machine')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Type,

        [SupportsWildcards()]
        [string]$Name
    )
    begin {
        [bool] $isUser = $Type -eq 'User'
        $predicate = $Name ? { $_.Name.SubString(0, $_.Name.LastIndexof(' ')) -like $Name } : { $_.Name -NotIn 'PSChildName', 'PSDrive', 'PSParentPath', 'PSPath', 'PSProvider' }
    }
    process {
        $drive = $isUser ? 'HKCU:' : 'HKLM:'
        Get-ItemProperty "$drive\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" |
            Get-Member -MemberType NoteProperty |
            Where-Object $predicate |
            Select-Object Name, @{
                L = 'FileName'
                E = {
                    $def = $_.Definition
                    $fileName = $def.SubString($def.IndexOf('=') + 1)
                    $isUser ? $fileName : (Join-Path "$env:windir\Fonts" $fileName)
                }
            }
    }
}
