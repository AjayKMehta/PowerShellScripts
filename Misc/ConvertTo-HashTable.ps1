function ConvertTo-Hashtable {
    <#
    .SYNOPSIS
        Convert InputObject to Hashtable based on KeyField and ValueField.
    .DESCRIPTION
        Convert InputObject to Hashtable based on KeyField and ValueField.
    .EXAMPLE
        gci | ConvertTo-Hashtable -KeyField Name -ValueField LastwriteTime
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [Alias()]
    [OutputType([Hashtable])]
    Param (
        # Param1 help description
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [object[]] $InputObject,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $KeyField,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, Position = 1)]
        [String] $ValueField
    )
    begin {
        $result = @{}
    }
    process {
        foreach ($item in $InputObject) {
            $key = $item | Select-Object -ExpandProperty $KeyField
            $value = $item | Select-Object -ExpandProperty $ValueField
            $result.Add($key, $value)
        }
    }
    end {
        $result
    }
}