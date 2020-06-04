function Format-Xml {
    <#
    .SYNOPSIS
        Formats XML file or document.
    .DESCRIPTION
        Formats XML file based on XmlWriterSettings supplied . If the input is a document, output is a string. If file, it will overwrite existing file with desired output.
    .PARAMETER LiteraPath
        Path to an XML file. Can take input from pipeline.
    .PARAMETER XML
        XML Document
    .PARAMETER CheckCharacters
        Indicates whether to check that characters are in the legal XML character set.
        The default value is true.
    .PARAMETER ConformanceLevel
        Indicates whether to check that output is a well-formed XML 1.0 document or fragment.
        Default value is [System.Xml.ConformanceLevel]::Document.
    .PARAMETER DoNotEscapeUriAttributes
        Indicates whether the XmlWriter does not escape URI attributes. The default value is false.
    .PARAMETER Encoding
        Specify the type of text encoding to use. Defaults to UTF8.
    .PARAMETER Indent
        Toggle indenting XML elements. Defaults to true.
    .PARAMETER IndentChars
        The character string to use when indenting. This is used when the Indent parameter is set to true.
    .PARAMETER NamespaceHandling
        Indicates whether to remove duplicate namespace declarations when writing XML content. By default, it does not.
    .PARAMETER NewLineChars
        The character string to use for line breaks.
    .PARAMETER NewLineHandling
        Indicates whether to normalize line breaks in the output.
    .PARAMETER NewLineOnAttributes
        Indicates whether to write attributes on a new line. Defaults to true.
    .PARAMETER OmitXmlDeclaration
        Indicates whether to omit an XML declaration. Defaults to false.
    .EXAMPLE
        $settings = New-XmlWriterSettings -OmitXmlDeclaration
        Format-Xml -LiteralPath 'c:\git\test\test.csproj' -Settings $settings
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.xml.xmlwritersettings?view=netcore-3.1
    #>
    param
    (
        [ValidatePathExists()]
        [Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath', 'FullName')]
        [string] $LiteralPath,

        [Parameter(ParameterSetName = "XML", Mandatory = $true, Position = 0 )]
        [XML] $XML,

        [Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, Position = 0)]
        [Parameter(ParameterSetName = "XML", Mandatory = $true, Position = 1)]
        [System.Xml.XmlWriterSettings] $Settings

    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'LiteralPath' ) {
            $xml = [xml](Get-Content $LiteralPath)
            $xmlWriter = [Xml.XmlWriter]::Create($LiteralPath, $Settings)
            $xml.Save($xmlWriter)
            $xmlWriter.Close()
        } else {
            [System.Text.StringBuilder] $sb = [System.Text.StringBuilder]::new()
            $xmlWriter = [Xml.XmlWriter]::Create($sb, $Settings)
            $xml.Save($xmlWriter)
            $xmlWriter.Close()
            $sb.ToString()
        }
    }
}
