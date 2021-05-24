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
        if ($Language -eq 'VisualStudioCode') {
            Invoke-RestMethod 'https://raw.githubusercontent.com/github/gitignore/master/Global/VisualStudioCode.gitignore'
        } else {
            Invoke-RestMethod "https://raw.githubusercontent.com/github/gitignore/master/$Language.gitignore"
        }
    }
}
