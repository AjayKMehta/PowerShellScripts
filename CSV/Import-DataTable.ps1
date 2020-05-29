function Import-DataTable {
    <#
    .SYNOPSIS
        Creates datatable from CSV file.
    .DESCRIPTION
        Creates datatable from CSV file. Column names are taken from first row.
    .PARAMETER LiteralPath
        This must be the path to a file. Wildcards are not supported.
    .PARAMETER Delimiter
        Specifies the delimiter that separates the property values in the CSV file. The default is a comma (,).
    .PARAMETER Encoding
        Specifies the encoding for the CSV file. Valid values are Unicode, UTF7, UTF8, ASCII, UTF32, BigEndianUnicode, Default, and OEM. The default is ASCII.
    .PARAMETER DetectEncodingFromByteOrderMarks
        If specified, code detects the encoding by looking at the first three bytes of the stream.
        It automatically recognizes UTF-8, little-endian Unicode, and big-endian Unicode text if the file starts with the appropriate byte order marks.
        Otherwise, the user-provided encoding is used.
    .INPUTS
        System.String
        You can pipe the path of a file to Import-DataTable.
    .NOTES
        Adapted from code in URL in Link section.
    .LINK
        https://blog.netnerds.net/2015/02/working-with-basic-net-datasets-in-powershell/
    #>
    [CmdletBinding()]
    [OutputType([System.Data.DataTable])]
    param
    (
        [ValidatePathExists(PathType = 'Leaf')]
        [Parameter(Mandatory = $true)]
        [Alias("PSPath", "File")]
        [string] $LiteralPath,

        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default,

        [ValidateNotNullOrEmpty()]
        [char] $Delimiter = ',',

        [switch] $DetectEncodingFromByteOrderMarks
    )

    [Regex] $splitBy = [regex]::new($Delimiter + '(?=(?:[^"]*\"[^"]*")*(?![^"]*"))')
    [string] $file = Convert-Path $LiteralPath

    $result = [System.Data.DataTable]::new()
    $reader = [System.IO.StreamReader]::new($file, $Encoding, $DetectEncodingFromByteOrderMarks)
    [bool] $firstRow = $true

    while ($line = $reader.ReadLine()) {
        [object[]] $vals = $splitBy.Split($line)
        if ($firstRow) {
            foreach ($col in $vals) {
                # Necessary to handle escaped column names!
                $null = $result.Columns.Add(($col -replace '^"([^"]*)"$', '$1'))
            }
            $firstRow = $false
        } else {
            $null = $result.Rows.Add($vals)
        }
    }
    # Add comma before so PowerShell doesn't convert to Object[]!
    ,$result
}
