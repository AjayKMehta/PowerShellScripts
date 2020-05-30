function Import-DataTable {
    <#
    .SYNOPSIS
        Creates datatable from CSV file.
    .DESCRIPTION
        Creates datatable from CSV file. Column names are taken from first non-skipped row or can be provided.
    .PARAMETER LiteralPath
        This must be the path to a file. Wildcards are not supported.
    .PARAMETER Delimiter
        Specifies the delimiter that separates the property values in the CSV file. The default is a comma (,).
    .PARAMETER Columns
        Specifies an array of strings to use for column names.
    .PARAMETER Encoding
        Specifies the encoding for the CSV file. Valid values are Unicode, UTF7, UTF8, ASCII, UTF32, BigEndianUnicode, Default, and OEM. The default is UTF8.
    .PARAMETER Skip
        Specifies the number of lines from the beginning of the file to skip.
    .PARAMETER DetectEncodingFromByteOrderMarks
        If specified, code detects the encoding by looking at the first three bytes of the stream.
        It automatically recognizes UTF-8, little-endian Unicode, and big-endian Unicode text if the file starts with the appropriate byte order marks.
        Otherwise, the user-provided encoding is used.
    .INPUTS
        System.String
        You can pipe the path of a file to Import-DataTable.
    .NOTES
        Idea based on code in URL in Link section.
    .LINK
        https://blog.netnerds.net/2015/02/working-with-basic-net-datasets-in-powershell/
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Data.DataTable])]
    param
    (
        [ValidatePathExists(PathType = 'Leaf')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Columns', ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Default', Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath', 'File')]
        [string] $LiteralPath,

        [ValidateNotNullOrEmpty()]
        [Alias('Separator')]
        [char] $Delimiter = ',',

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true, ParameterSetName = 'Columns')]
        [string[]] $Columns,

        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default,

        [int] $Skip = 0,

        [switch] $DetectEncodingFromByteOrderMarks
    )
    process {
        [Regex] $splitBy = [regex]::new($Delimiter + '(?=(?:[^"]*\"[^"]*")*(?![^"]*"))')
        [string] $file = Convert-Path $LiteralPath

        $result = [System.Data.DataTable]::new()
        $reader = [System.IO.StreamReader]::new($file, $Encoding, $DetectEncodingFromByteOrderMarks)

        [bool] $hasHeader = $false
        if ($PSCmdlet.ParameterSetName -eq 'Columns') {
            foreach ($col in $Columns) {
                $null = $result.Columns.Add($col)
            }
            $hasHeader = $true
        }

        [int] $i = 0
        while ($line = $reader.ReadLine()) {
            $i++
            if ($i -le $Skip) {
                continue
            }
            Write-Verbose "Processing line $i of $file"
            Write-Debug "line $i of $($file): $line"
            [object[]] $vals = $splitBy.Split($line)
            if (!$hasHeader) {
                foreach ($col in $vals) {
                    # Necessary to handle escaped column names!
                    $null = $result.Columns.Add(($col -replace '^"([^"]*)"$', '$1'))
                }
                $hasHeader = $true
            } else {
                $null = $result.Rows.Add($vals)
            }
        }
        $numLines = if ($Skip -gt $i) {0} else {$i - $Skip}
        Write-Verbose "Read $numLines lines of $file"
        # Add comma before so PowerShell doesn't convert to Object[]!
        , $result
    }
}
