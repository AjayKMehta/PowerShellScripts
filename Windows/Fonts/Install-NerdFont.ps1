. "$PSScriptRoot\Install-Font.ps1"
function Install-NerdFont {
    [CmdletBinding(DefaultParameterSetName = 'FontType')]
    param (
        [ValidateSet(
            '0xProto',
            '3270',
            'Agave',
            'AnonymousPro',
            'Arimo',
            'AurulentSansMono',
            'BigBlueTerminal',
            'BitstreamVeraSansMono',
            'CascadiaCode',
            'CascadiaMono',
            'CodeNewRoman',
            'ComicShannsMono',
            'CommitMono',
            'Cousine',
            'D2Coding',
            'DaddyTimeMono',
            'DejaVuSansMono',
            'DepartureMono',
            'DroidSansMono',
            'EnvyCodeR',
            'FantasqueSansMono',
            'FiraCode',
            'FiraMono',
            'GeistMono',
            'Gohu',
            'Go-Mono',
            'Hack',
            'Hasklig',
            'HeavyData',
            'Hermit',
            'iA-Writer',
            'IBMPlexMono',
            'Inconsolata',
            'InconsolataGo',
            'InconsolataLGC',
            'IntelOneMono',
            'Iosevka',
            'IosevkaTerm',
            'IosevkaTermSlab',
            'JetBrainsMono',
            'Lekton',
            'LiberationMono',
            'Lilex',
            'MartianMono',
            'Meslo',
            'Monaspace',
            'Monofur',
            'Monoid',
            'Mononoki',
            'MPlus',
            'NerdFontsSymbolsOnly',
            'Noto',
            'OpenDyslexic',
            'Overpass',
            'ProFont',
            'ProggyClean',
            'Recursive',
            'RobotoMono',
            'ShareTechMono',
            'SourceCodePro',
            'SpaceMono',
            'Terminus',
            'Tinos',
            'Ubuntu',
            'UbuntuMono',
            'UbuntuSans',
            'ZedMono',
            'VictorMono'
        )]
        [string] $FontName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [Version] $Version,

        [Parameter(ParameterSetName = 'FontType')]
        [ValidateSet('OpenType', 'TrueType', 'All')]
        [string] $FontType = 'All',

        [Parameter(Mandatory = $true, ParameterSetName = 'Pattern')]
        [string] $Pattern,

        [ValidateSet('User', 'Machine')]
        [Parameter(Mandatory = $true)]
        [string]$Type,

        [switch] $Choose,

        [switch] $Clobber,

        [switch] $Log
    )
    begin {
        $downloadFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) `
            -ChildPath ($FontName + (Get-Date).ToString('yyyyMMddHHmmss'))

        $redirect = $Log ? [System.IO.Path]::GetTempFileName().Replace('.tmp', '.log') : $null
    }

    process {
        if ($Version) {
            $tag = "v$Version"
        }
        [string] $fileName = "$FontName.tar.xz"
        [string] $tempFile = Join-Path $downloadFolder $fileName
        gh release download --repo ryanoasis/nerd-fonts $tag --pattern $fileName -O $tempFile --clobber
        if ($LASTEXITCODE -eq 0) {
            7z e $tempFile "-o$downloadFolder" '-aoa' > $redirect
            if ($LASTEXITCODE -eq 0) {
                $tarFile = $tempFile.Replace('.xz', '')

                if ($PSCmdlet.ParameterSetName -eq 'FontType') {
                    $char = switch ($FontType) {
                        'OpenType' { 'o' }
                        'TrueType' { 't' }
                        default { '?' }
                    }
                    $Pattern = "*.${Char}tf"
                }
                7z e $tarFile "-o$downloadFolder" $Pattern -aoa > $redirect
                $fonts = Get-ChildItem -LiteralPath $downloadFolder -Filter $Pattern
                if ($Choose) {
                    $fonts = $fonts | Out-GridView -Title "Select fonts for $FontName" -OutputMode Multiple
                }
                $fonts | Install-Font -Type $Type -Clobber:$Clobber
            }
        } else {
            Write-Error "Unable to download $FontName. Check version specified."
        }
    }
    end {
        Remove-Item "$downloadFolder\*" -Recurse -Force -ErrorAction SilentlyContinue

        if ($Log) {
            Write-Verbose "Please check log $redirect."
        }
    }
}
