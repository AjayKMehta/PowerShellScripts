function Remove-EmptyDirectory {
    <#
    .SYNOPSIS
        Deletes empty subfolders in Path.
    .DESCRIPTION
        Deletes empty subfolders in Path. If -Recurse is specified, it will
        check all subfolders of Path.
    .PARAMETER Path
        Path to a folder. Wildcards are supported.
    .PARAMETER Filter
        Specifies a filter to qualify the Path parameter.
    .PARAMETER Recurse
        If set, it will search subfolders as well.
    .PARAMETER Force
        Allows the cmdlet to get items that otherwise can't be accessed by the
        user, such as hidden or system files.
    .EXAMPLE
        Remove-EmptyDirectory "C:\temp"
    .EXAMPLE
        gci "D:\temp\*\*" -Directory | Remove-EmptyDirectory -Recurse -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [SupportsWildcards()]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath')]
        [string[]] $Path,
        [string] $Filter,
        [switch] $Recurse,
        [switch] $Force
    )
    begin {
        $PsBoundParameters['Confirm'] = $false
        $PsBoundParameters['Verbose'] = $false
        $PsBoundParameters['WhatIf'] = $false
        @('Recurse', 'Filter').ForEach( { $null = $PSBoundParameters.Remove($_) })
    }
    process {
        $null = $PsBoundParameters.Remove('Path')
        Get-ChildItem -Path $Path -Directory -Recurse:$Recurse -Filter $Filter -Force:$Force |
            Where-Object { $_.GetFiles().Count -eq 0 } |
            # Delete in bottom-up order to avoid issues
            Sort-Object @{Expression = { $_.FullName.Length }; Descending = $true } |
            ForEach-Object {
                $folder = $_.FullName
                if (($_.GetDirectories().Count -eq 0) -and
                    ($PSCmdlet.ShouldProcess($folder, 'Remove Directory'))) {
                    Remove-Item $folder @PsBoundParameters
                }
            }
    }
}
