function Test-All {
    <#
    .SYNOPSIS
        Returns True if Predicate evaluates to True for all supplied values.
    .DESCRIPTION
        Returns True if Predicate evaluates to True for all supplied values.
        If value is null, then the result is true.
    .PARAMETER Values
        The values you want to test.
    .PARAMETER Predicate
        The predicate to test values with.
    .EXAMPLE
        Test-All @("a","b","?") {param([string] $s) $s -match '\w' }
    .EXAMPLE
        Test-All @("a","b") {param($s) $s.Length -eq 1 }
    #>
    param
    (
        $Values,
        [ValidateNotNull()]
        [ScriptBlock] $Predicate
    )

    foreach ($value in $Values) {
        if (!$Predicate.Invoke($value)) {
            return $false
        }
    }
    return $true
}