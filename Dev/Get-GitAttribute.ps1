function Get-GitAttributes {
    <#
    .EXAMPLE
        'R', 'Python' | Get-GitAttributes | Add-Content '.\.gitattributes'
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('C++', 'CSharp', 'Common', 'Go', 'Java', 'Python', 'R', 'VisualStudio', 'Web')]
        [Parameter(ValueFromPipeline = $true)]
        [string]$Language
    )
    process {
        $null = $PSBoundParameters.Remove('Language')
        [uri] $url = "https://raw.githubusercontent.com/alexkaratarakis/gitattributes/master/$Language.gitattributes"
        Invoke-RestMethod -Uri $url @PSBoundParameters
    }
}
