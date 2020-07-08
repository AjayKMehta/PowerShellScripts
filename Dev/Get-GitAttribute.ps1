function Get-GitAttributes {
    <#
    .EXAMPLE
        'R', 'Python' | Get-GitAttributes | Add-Content '.\.gitatributes'
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('C++', 'CSharp', 'Common', 'Go', 'Java', 'Python', 'R', 'VisualStudio', 'Web')]
        [Parameter(ValueFromPipeline = $true)]
        [string]$Language
    )
    process {
        Invoke-RestMethod "https://raw.githubusercontent.com/alexkaratarakis/gitattributes/master/$Language.gitattributes"
    }
}