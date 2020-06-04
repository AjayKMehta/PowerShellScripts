function New-XmlWriterSettings {
    <#
    .SYNOPSIS
        Creates settings used by XmlWriter.
    .DESCRIPTION
        Creates settings used by XmlWriter.
    .PARAMETER CheckCharacters
        Indicates whether to check that characters are in the legal XML character set.
        The default value is true.
    .PARAMETER ConformanceLevel
        Indicates whether to check that output is a well-formed XML 1.0 document or fragment.
        Default value is [System.Xml.ConformanceLevel]::Document.
    .PARAMETER DoNotEscapeUriAttributes
        If set, the XmlWriter does not escape URI attributes.
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
        If set, write attributes on a new line.
    .PARAMETER OmitXmlDeclaration
        If set, omit an XML declaration.
    .EXAMPLE
        $settings = New-XmlWriterSettings -OmitXmlDeclaration
    #>
    param
    (
        [Alias('cc')]
        [bool] $CheckCharacters = $true,

        [Xml.ConformanceLevel] $ConformanceLevel = [Xml.ConformanceLevel]::Document,

        [Alias('DoNotEscape', 'NoEscape')]
        [switch] $DoNotEscapeUriAttributes,

        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8,

        [bool] $Indent = $true,
        [string] $IndentChars = '  ',

        [Alias('nsh')]
        [System.Xml.NamespaceHandling] $NamespaceHandling = [System.Xml.NamespaceHandling]::Default,

        [Alias('nlc')]
        [string] $NewLineChars = "`r`n",

        [Alias('nlh')]
        [System.Xml.NewLineHandling] $NewLineHandling = [System.Xml.NewLineHandling]::Replace,

        [Alias('nloa')]
        [switch] $NewLineOnAttributes,

        [Alias('oxd', 'omitdec')]
        [switch] $OmitXmlDeclaration
    )
    $params = Get-ParameterValue $MyInvocation.MyCommand
    $params.Add('CloseOutput', $true)
    New-Object System.Xml.XmlWriterSettings -Property $params
}
