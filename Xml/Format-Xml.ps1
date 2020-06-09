function Format-Xml {
    <#
    .SYNOPSIS
        Formats XML file or document.
    .DESCRIPTION
        Formats XML file based on XmlWriterSettings supplied . If the input is a document, output is a string. If file, it will overwrite existing file with desired output.
    .PARAMETER LiteraPath
        Path to an XML file. Can take input from pipeline.
    .PARAMETER Xml
        XML Document
    .PARAMETER Settings
        Object ot type System.Xml.XmlWriterSettings.
    .EXAMPLE
        $settings = New-XmlWriterSettings -OmitXmlDeclaration
        Format-Xml -LiteralPath 'c:\git\test\test.csproj' -Settings $settings
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.xml.xmlwritersettings?view=netcore-3.1
    #>
    [CmdletBinding(DefaultParameterSetName = "LiteralPath", PositionalBinding = $false)]
    param
    (
        [ValidatePathExists()]
        [Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath', 'FullName')]
        [string] $LiteralPath,

        [Parameter(ParameterSetName = "XML", Mandatory = $true, Position = 0 )]
        [XML] $Xml,

        [Parameter(ParameterSetName = "LiteralPath", Mandatory = $true, Position = 0)]
        [Parameter(ParameterSetName = "XML", Mandatory = $true, Position = 1)]
        [System.Xml.XmlWriterSettings] $Settings

    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'LiteralPath' ) {
            $Xml = [xml](Get-Content $LiteralPath)
            $xmlWriter = [Xml.XmlWriter]::Create($LiteralPath, $Settings)
            $Xml.Save($xmlWriter)
            $xmlWriter.Close()
        } else {
            [System.Text.StringBuilder] $sb = [System.Text.StringBuilder]::new()
            $xmlWriter = [Xml.XmlWriter]::Create($sb, $Settings)
            $Xml.Save($xmlWriter)
            $xmlWriter.Close()
            $sb.ToString()
        }
    }
}
