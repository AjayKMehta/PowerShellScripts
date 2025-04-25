Add-Type -AssemblyName PresentationCore

function Install-Font {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Alias('Path')]
        [ValidateScript({ $_.Exists -and $_.Extension -in '.otf' , '.ttf' })]
        [Parameter(ValueFromPipeline = $true)]
        [System.IO.FileInfo] $FontFile,

        [ValidateSet('User', 'Machine')]
        [Parameter(Mandatory = $true)]
        [string]$Type,

        [switch] $Clobber
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
        $null = $PSBoundParameters.Remove('FontFile')

        [string] $fontPath = $fontFile.FullName
        $gt = [Windows.Media.GlyphTypeface]::new($fontPath)
        $family = $gt.FamilyNames['en-us'] ?? $gt.Win32FamilyNames['en-us']
        $face = $gt.FaceNames['en-us'] ?? $gt.Win32FaceNames['en-us']
        $fontName = "$family $face".Trim()

        $fontName = switch ($fontFile.Extension) {
            '.ttf' { "$fontName (TrueType)" }
            '.otf' { "$fontName (OpenType)" }
        }

        if ($PSCmdlet.ShouldProcess($fontPath, "Install font with font name '$fontName'")) {
            $installPath = Join-Path $installFolder $FontFile.Name

            $installed = Test-Path $installPath -PathType Leaf

            if ($Clobber -or !$installed) {
                Copy-Item -Path $fontPath -Destination $installPath -Force @PSBoundParameters -WhatIf:$false

                if ($?) {
                    if (Get-ItemProperty -Name $fontName -Path $registryPath @PSBoundParameters) {
                        Write-Verbose "Font already registered: $fontFile"
                    } else {
                        $newItemPropertySplat = @{
                            Name         = $fontName
                            Path         = $registryPath
                            PropertyType = 'string'
                            Value        = $fontFile.Name
                            Force        = $true
                        }
                        New-ItemProperty @newItemPropertySplat @PSBoundParameters -WhatIf:$false | Out-Null
                    }
                }
            } elseif ($installed) {
                Write-Verbose "Font $fontPath is already installed."
            }
        }
    }
}
