function Get-FSAccessRule {
    <#
    .SYNOPSIS
        Returns FileSystemAccessRule objects for Path and Principal.
    .DESCRIPTION
        Returns FileSystemAccessRule objects for Path and Principal.
    .PARAMETER Path
        The path whose access you need to check.
    .PARAMETER Principal
        The principal for whom you need to check access.
    .EXAMPLE
        Get-FSAccessRule -Path "C:\temp"
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param
    (
        [SupportsWildcards()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Path,
        [Parameter(Mandatory = $false, Position = 0)]
        [System.Security.Principal.WindowsPrincipal] $Principal = (Get-CurrentUser)
    )

    (Get-Acl -Path $Path -ea Stop).Access |
        Where-Object { $Principal.IsInRole($_.IdentityReference) }
}
