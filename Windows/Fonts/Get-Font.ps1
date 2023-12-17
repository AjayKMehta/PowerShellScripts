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
        $drive = $isUser ? 'HKCU:' : 'HKLM:'
        $excluded = 'PSChildName', 'PSDrive', 'PSParentPath', 'PSPath', 'PSProvider'
        $predicate = if ($Name) {
            {
                # Font is <Font Family> <Style> (<FontType>).
                $index = $_.Name.LastIndexof(' ')
                $check = ($index -eq -1) ? $_.Name : $_.Name.SubString(0, $index)
                $_.Name -NotIn $excluded -and $check -like $Name
            }
        } else {
            { $_.Name -NotIn $excluded }
        }
    }
    process {
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
