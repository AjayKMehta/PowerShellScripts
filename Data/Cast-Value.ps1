#TODO: Add dynamic parameter KeyField if UseDefaults not specified.
function Cast-Value {
    <#
    .SYNOPSIS
        Tries to cast specified properties based on supplied hashtable.
    .DESCRIPTION
        Tries to cast specified properties based on supplied hashtable.
    .PARAMETER InputObject
        The object whose properties you wish to convert. Can take values from the pipeline.
    .PARAMETER PropertyTypeMap
        A hashtable with property names as keys and types as values.
    .PARAMETER UseDefaults
        If specified, will use default value of type if cast fails. For example, if we try to cast x.Value which has value "Test" to [int], this will fail.
        So, assign x.Value to 0 (default value for [int]).
    .EXAMPLE
        $test = @"
        a,b,c
        1,2,3
        a,12,4
        "@

        # Get an error about invalid cast.
        $test | ConvertFrom-Csv | Cast-Value @{a=[int]}
    .EXAMPLE
        # Uses $test from first example. Value is 0 when cast to [int] fails.
        $test | ConvertFrom-Csv | Cast-Values @{a=[int]} -UseDefaults
    .EXAMPLE
        # Uses $test from first example.
        $test | ConvertFrom-Csv | Cast-Value @{a=[int]} -ea SilentlyContinue -ErrorVariable e
        $e.Exception.Data # This has detailed error info
    #>
    [Cmdletbinding(PositionalBinding = $false)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject] $InputObject,
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable] $PropertyTypeMap,
        [switch] $UseDefaults
    )

    begin {
        [int] $ctr = 0
    }

    process {
        foreach ($property in $PropertyTypeMap.Keys) {
            $type = $PropertyTypeMap.$property
            if ($type -ne [string]) {
                $origValue = $Inputobject.$property
                $parseInfo = Parse-Value ($origvalue) $type
                if ($UseDefaults -or $parseInfo.IsParsed) {
                    $InputObject.$property = $parseInfo.Value
                } else {
                    [System.Exception] $exception = New-Object System.Exception
                    @{"Id" = $ctr; "Value" = $origValue; "Field" = $property; "Type" = $type }.GetEnumerator() |
                    ForEach-Object { $exception.data.Add($_.Key, $_.Value) }

                    if ($origValue -is [string]) { $origValue = "`"$origValue`"" }
                    Write-Error -Message "Cannot convert value for $property ($origValue) to type $type." -Exception $exception
                }
            }
        }
        $InputObject
        $ctr++
    }
}