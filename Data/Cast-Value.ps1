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
        If specified, will use default value of type if cast fails. For example,
        if we try to cast x.Value which has value "Test" to [int], this will fail.
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
        $test | ConvertFrom-Csv | Cast-Value @{a=[int]} -UseDefaults
    .EXAMPLE
        # Uses $test from first example.
        $test | ConvertFrom-Csv | Cast-Value @{a=[int]} -ea SilentlyContinue -ErrorVariable e
        $e.Exception.Data # This has detailed error info
    .EXAMPLE
        $test = @"
        id,a,b,c
        A,1,2,3
        B,a,12,4
        "@
        $test | ConvertFrom-Csv | Cast-Value -Map @{a=[int]} -ea SilentlyContinue -ErrorVariable e -KeyField id
        $e.Exception.Data
    #>
    [Cmdletbinding(PositionalBinding = $false)]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [psobject] $InputObject,
        [Parameter(Mandatory = $true, Position = 0)]
        [Alias('Map', 'TypeMap')]
        [hashtable] $PropertyTypeMap,
        [switch] $UseDefaults
    )

    dynamicParam {
        if (!$PSBoundParameters.ContainsKey('UseDefaults')) {
            $paramAttrib = New-ParameterAttribute
            $aliasAttrib = [Alias]::new(@('Id', 'IdField'))
            $dynamicParam = New-DynamicParameter -Name 'KeyField' -Type ([string]) -Attribute $paramAttrib, $aliasAttrib

            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            $paramDictionary.Add('KeyField', $dynamicParam)
            $paramDictionary
        }
    }

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
                    $exception = [System.InvalidCastException]::new()
                    @{'Record#' = $ctr; 'Value' = $origValue; 'Field' = $property; 'Type' = $type }.GetEnumerator() |
                        ForEach-Object { $exception.data.Add($_.Key, $_.Value) }

                    if ($origValue -is [string]) { $origValue = "`"$origValue`"" }
                    [string] $KeyField = $null
                    if ($PSBoundParameters.TryGetValue('KeyField', [ref] $KeyField)) {
                        $keyValue = $Inputobject.$KeyField
                        $exception.data.Add("Key ($KeyField)", $keyValue)
                        if ($keyValue -is [string]) { $keyValue = "`"$keyValue`"" }
                        $message = "Cannot convert value for record with {$keyField} = $keyValue and field {$property} = $origValue to type $type."
                    } else {
                        $message = "Cannot convert value for field {$property} = $origValue to type $type."
                    }
                    Write-Error -Message $message -Exception $exception
                }
            }
        }
        $InputObject
        $ctr++
    }
}
