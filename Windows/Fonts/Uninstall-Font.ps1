. "$PSScriptRoot\Get-Font.ps1"

function Uninstall-Font {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Alias('Name')]
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $FontName,

        [ValidateSet('User', 'Machine')]
        [Parameter(Mandatory = $true)]
        [string]$Type
    )
    begin {
        [bool] $isUser = $Type -eq 'User'
        [string] $drive = $isUser ? 'HKCU:' : 'HKLM:'
        [string] $installFolder = $isUser ? "${env:LOCALAPPDATA}\Microsoft\Windows\Fonts" : "${env:windir}\Fonts\"
        [string] $registryPath = "$drive\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

        @('ErrorAction', 'Type', 'Clobber').ForEach( { $null = $PSBoundParameters.Remove($_) })
    }
    process {
        $PsBoundParameters['Verbose'] = $false
        $PsBoundParameters['ErrorAction'] = 'SilentlyContinue'

        $null = $PSBoundParameters.Remove('FontName')

        $fonts = Get-Font -Name $FontName -Type $Type

        if ($PSCmdlet.ShouldProcess($fontName, 'Uninstall font')) {
            foreach ($font in $fonts) {
                $fontPath = $font.FileName

                if (Test-Path $fontPath) {
                    Remove-Item -LiteralPath $fontPath -Force @PSBoundParameters -WhatIf:$false

                    if ($?) {
                        $removeItemPropertySplat = @{
                            Name  = $fontName
                            Path  = $registryPath
                            Force = $true
                        }
                        Remove-ItemProperty @removeItemPropertySplat @PSBoundParameters -WhatIf:$false | Out-Null
                    }
                } else {
                    Write-Warning "Font $fontName is not installed: file ($fontPath) does not exist!"
                }
            }
        }
    }
}
