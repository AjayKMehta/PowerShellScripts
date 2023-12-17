function Get-Font {
    <#
    .SYNOPSIS
        List installed fonts.
    .DESCRIPTION
        List installed fonts (system or user) based on information in registry.
    .EXAMPLE
        Get-Font -Type Machine -Name *Nerd* | Select-Object -First 3
    .EXAMPLE
        'A*', 'T*' | Get-Font -Type Machine
    .NOTES
        Based on https://superuser.com/a/1534136/448598.
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [ValidateSet('User', 'Machine')]
        [Parameter(Mandatory = $true)]
        [string]$Type,

        [SupportsWildcards()]
        [Parameter(ValueFromPipeline = $true)]
        [string]$Name
    )
    begin {
        [bool] $isUser = $Type -eq 'User'
        $regPath = Join-Path ($isUser ? 'HKCU:' : 'HKLM:') '\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        $excluded = 'PSChildName', 'PSDrive', 'PSParentPath', 'PSPath', 'PSProvider'
    }
    process {
        $predicate = if ($Name) {
            {
                # Font is <Font Family> <Style> (<FontType>).
                $index = $_.Name.LastIndexOf(' ')
                $check = ($index -eq -1) ? $_.Name : $_.Name.SubString(0, $index)
                $_.Name -NotIn $excluded -and $check -like $Name
            }
        } else {
            { $_.Name -NotIn $excluded }
        }
        Get-ItemProperty $regPath |
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
