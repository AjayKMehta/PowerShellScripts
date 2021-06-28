using namespace Microsoft.VisualBasic.FileIO

function Import-DataTable {
    <#
    .SYNOPSIS
        Creates datatable from CSV file.
    .DESCRIPTION
        Creates datatable from CSV file. Column names are taken from first non-skipped row or can be provided.
    .INPUTS
        System.String
        You can pipe the path of a file to Import-DataTable.
    .NOTES
        Inspired by URL in Link section.
    .LINK
        https://blog.netnerds.net/2015/02/working-with-basic-net-datasets-in-powershell/
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default', PositionalBinding = $false)]
    [OutputType([System.Data.DataTable])]
    param
    (
        [ValidatePathExists(PathType = 'Leaf')]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath', 'File')]
        # This must be the path to a file. Wildcards are not supported.
        [string] $LiteralPath,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Default')]
        [Alias('Separator')]
        # Uses the list separator for the current culture as the item delimiter.
        [string[]] $Delimiter = ',',

        [Parameter(ParameterSetName = 'Culture')]
        # Uses the list separator for the current culture as the item delimiter.
        [switch] $UseCulture,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $false)]
        # Specifies an array of strings to use for column names.
        [string[]] $Header,

        # Specifies the encoding for the CSV file. Valid values are Unicode,
        # UTF7, UTF8, ASCII, UTF32, BigEndianUnicode, Default, and OEM. The
        # default is UTF8.
        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default,

        # Specifies the number of *uncommented* lines from the beginning of the file to skip.
        [int] $Skip = 0,

        # If specified, code detects the encoding by looking at the first three
        # bytes of the stream. It automatically recognizes UTF-8, little-endian
        # Unicode, and big-endian Unicode text if the file starts with the
        # appropriate byte order marks. Otherwise, the user-provided encoding is
        # used.
        [switch] $DetectEncoding,

        [Parameter(Mandatory = $false)]
        # Strings whose presence at beginning of lines indicates that line is a
        # comment and should be ignored.
        [string[]] $CommentTokens,

        # If set, trim whitespace from values.
        [switch] $TrimWhiteSpace
    )
    begin {
        if ($UseCulture) {
            $Delimiter = [Cultureinfo]::CurrentCulture.TextInfo.ListSeparator
        }
    }
    process {
        [string] $file = Convert-Path $LiteralPath

        $result = [System.Data.DataTable]::new()
        $reader = [TextFieldParser]::new($file, $Encoding, $DetectEncoding)
        $reader.TextFieldType = [FieldType]::Delimited
        $reader.Delimiters = $Delimiter
        if ($CommentTokens) {
            $reader.CommentTokens = $CommentTokens
        }
        if ($TrimWhiteSpace) {
            $reader.TrimWhiteSpace = $TrimWhiteSpace
        }

        [bool] $hasHeader = $false
        if ($Header) {
            foreach ($col in $Header) {
                $null = $result.Columns.Add($col)
            }
            $hasHeader = $true
        }

        [int] $i = 0
        while (!$reader.EndOfData) {
            try {
                $vals = $reader.ReadFields()
                $i++
                if ($i -le $Skip) {
                    continue
                }
                Write-Verbose "Processing line $i of $file"
                Write-Debug "line $i of $($file): $line"
                if (!$hasHeader) {
                    foreach ($col in $vals) {
                        $null = $result.Columns.Add(($col))
                    }
                    $hasHeader = $true
                } else {
                    $null = $result.Rows.Add($vals)
                }
            } catch [MalformedLineException] {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
        $numLines = if ($Skip -gt $i) { 0 } else { $i - $Skip }
        Write-Verbose "Read $numLines lines of $file"
        # Add comma before so PowerShell doesn't convert to Object[]!
        , $result
    }
}
