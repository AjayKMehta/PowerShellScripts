using namespace System.Xml

function New-XmlWriterSettings {
    <#
    .SYNOPSIS
        Creates settings used by XmlWriter.
    .DESCRIPTION
        Creates settings used by XmlWriter.
    .PARAMETER CheckCharacters
        Indicates whether to check that characters are in the legal XML
        character set. The default value is true.
    .PARAMETER ConformanceLevel
        Indicates whether to check that output is a well-formed XML 1.0 document
        or fragment. Default value is [System.Xml.ConformanceLevel]::Document.
    .PARAMETER DoNotEscapeUriAttributes
        If set, the XmlWriter does not escape URI attributes.
    .PARAMETER Encoding
        Specify the type of text encoding to use. Defaults to UTF8.
    .PARAMETER Indent
        Toggle indenting XML elements. Defaults to true.
    .PARAMETER IndentChars
        The character string to use when indenting. This is used when the Indent
        parameter is set to true.
    .PARAMETER NamespaceHandling
        Indicates whether to remove duplicate namespace declarations when
        writing XML content. By default, it does not.
    .PARAMETER NewLineChars
        The character string to use for line breaks.
    .PARAMETER NewLineHandling
        Indicates whether to normalize line breaks in the output.
    .PARAMETER NewLineOnAttributes
        If set, write attributes on a new line.
    .PARAMETER OmitXmlDeclaration
        If set, omit an XML declaration.
    .OUTPUTS
        System.Xml.XmlWriterSettings
    .EXAMPLE
        $settings = New-XmlWriterSettings -OmitXmlDeclaration
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Xml.XmlWriterSettings])]
    param
    (
        [Alias('cc')]
        [bool] $CheckCharacters = $true,

        [ConformanceLevel] $ConformanceLevel = [ConformanceLevel]::Document,

        [Alias('DoNotEscape', 'NoEscape')]
        [switch] $DoNotEscapeUriAttributes,

        [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8,

        [bool] $Indent = $true,
        [string] $IndentChars = '  ',

        [Alias('nsh')]
        [NamespaceHandling] $NamespaceHandling = [NamespaceHandling]::Default,

        [Alias('nlc')]
        [string] $NewLineChars = [System.Environment]::NewLine,

        [Alias('nlh')]
        [NewLineHandling] $NewLineHandling = [NewLineHandling]::Replace,

        [Alias('nloa')]
        [switch] $NewLineOnAttributes,

        [Alias('oxd', 'omit')]
        [switch] $OmitXmlDeclaration
    )
    $params = Get-ParameterValue $MyInvocation
    $params.Add('CloseOutput', $true)
    New-Object -TypeName 'System.Xml.XmlWriterSettings' -Property $params
}
