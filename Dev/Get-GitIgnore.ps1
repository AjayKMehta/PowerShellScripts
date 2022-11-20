function Get-GitIgnore {
    <#
    .EXAMPLE
        'R', 'Python' | Get-GitIgnore | Add-Content '.\.gitignore'
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('C++', 'Go', 'Haskell', 'Java', 'Python', 'R', 'TeX', 'VisualStudio', 'VisualStudioCode')]
        [Parameter(ValueFromPipeline = $true)]
        [string]$Language
    )
    process {
        $null = $PSBoundParameters.Remove('Language')
        $part = $Language -eq 'VisualStudioCode' ? 'Global/VisualStudioCode' : $Language
        Invoke-RestMethod "https://raw.githubusercontent.com/github/gitignore/master/$part.gitignore" @PSBoundParameters
    }
}
