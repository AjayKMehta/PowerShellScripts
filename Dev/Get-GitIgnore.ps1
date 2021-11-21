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
        if ($Language -eq 'VisualStudioCode') {
            Invoke-RestMethod 'https://raw.githubusercontent.com/github/gitignore/master/Global/VisualStudioCode.gitignore' @PSBoundParameters
        } else {
            Invoke-RestMethod "https://raw.githubusercontent.com/github/gitignore/master/$Language.gitignore" @PSBoundParameters
        }
    }
}
