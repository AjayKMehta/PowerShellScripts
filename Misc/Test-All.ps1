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
        The scriptblock to test values with. Should return bool.
    .EXAMPLE
        Test-All @("a","b","?") {param([string] $s) $s -match '\w' }
    .EXAMPLE
        Test-All @("a","b") {param($s) $s.Length -eq 1 }
    #>
    [OutputType([bool])]
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
    $true
}
