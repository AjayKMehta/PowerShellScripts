filter Get-FullPath {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath')]
        [string[]] $Path
    )

    foreach ($pathItem in $Path) {
        if ($pathItem -eq 'C:') {
            $pathItem
        } else {
            # Can't use Convert-Path because it will fail if input path does not exist!
            $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($pathItem)
        }
    }
}
