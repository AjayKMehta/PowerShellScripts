function Test-Any {
    <#
    .SYNOPSIS
        Returns True if Predicate evaluates to True for any of the supplied values.
    .DESCRIPTION
        Returns True if Predicate evaluates to True for any of the supplied values.
        If value is null, then the result is false.
    .PARAMETER Values
        The values you want to test.
    .PARAMETER Predicate
        The scriptblock to test values with. Should return bool.
    .EXAMPLE
        Test-Any @("a","b","?") {param([string] $s) $s -match '\w' }
    .EXAMPLE
        Test-Any (1..3) {param($x) $x % 3 -eq 0}
    .EXAMPLE
        Test-Any $null {param($x) $x % 3 -eq 0}
    #>
    [OutputType([bool])]
    param
    (
        $Values,
        [ValidateNotNull()]
        [ScriptBlock] $Predicate
    )

    foreach ($value in $Values) {
        if ($Predicate.Invoke($value)) {
            return $true
        }
    }
    $false
}
