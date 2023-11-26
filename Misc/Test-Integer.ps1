function Test-Integer() {
    [OutputType([bool])]
    param($x)
    try {
        return ([int]$x -eq $x)
    } catch {
        return $false
    }
}
