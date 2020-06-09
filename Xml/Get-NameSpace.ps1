using namespace System.Collections.Generic

filter Get-Namespace {
    <#
    .SYNOPSIS
        Returns a dictionary whose key is prefix and value is value for each namespace for XML node.
    .DESCRIPTION
        Returns a dictionary whose key is prefix and value is value for each namespace for XML node.
    .PARAMETER Node
        XML node
    .PARAMETER DefaultNSPrefix
        Prefix for document's default namespace. Defaults to 'ns'.
    .EXAMPLE
        [xml](cat D:\git\*\*.csproj) | Get-NameSpace
    .EXAMPLE
        $xmlDoc = [xml](@'
        <?xml version="1.0" encoding="utf-8" ?>
                <e:Envelope xmlns:e="http://schemas.xmlsoap.org/soap/envelope/">
                  <e:Body>
                    <s:Search xmlns:s="http://schemas.microsoft.com/v1/Search">
                      <r:request xmlns:r="http://schemas.microsoft.com/v1/Search/metadata"
                                 xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                      </r:request>
                    </s:Search>
                  </e:Body>
                </e:Envelope>
        '@)

        Get-Namespace -Node $xmlDoc
    .EXAMPLE
        $xDoc = [System.Xml.Linq.XDocument]::Parse(@'
        <?xml version="1.0" encoding="utf-8" ?>
                <e:Envelope xmlns:e="http://schemas.xmlsoap.org/soap/envelope/">
                <e:Body>
                    <s:Search xmlns:s="http://schemas.microsoft.com/v1/Search">
                    <r:request xmlns:r="http://schemas.microsoft.com/v1/Search/metadata"
                                xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
                    </r:request>
                    </s:Search>
                </e:Body>
                </e:Envelope>
        '@)

        Get-Namespace -XNode $Doc
    .LINK
        http://stackoverflow.com/questions/767541/how-i-can-list-out-all-the-namespace-in-xml
    #>
    [Outputtype([Dictionary[string, string]])]
    [CmdletBinding(DefaultParameterSetName = 'Node', PositionalBinding = $false)]
    param
    (
        [ValidateNotNull()]
        [Parameter(Mandatory = $true, ParameterSetName = 'Node', ValueFromPipeline = $true)]
        [System.Xml.XmlNode] $Node,

        [ValidateNotNull()]
        [Parameter(Mandatory = $true, ParameterSetName = 'XNode', Position = 0)]
        [System.Xml.Linq.XNode] $XNode,

        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory = $false, ParameterSetName = 'Node', Position = 0)]
        [Parameter(Mandatory = $false, ParameterSetName = 'XNode', Position = 1)]
        [Alias('Prefix')]
        [string] $DefaultPrefix = 'ns'
    )
    if ($PSCmdlet.ParameterSetName -eq 'Node') {
        $Node.SelectNodes('//namespace::*[not(. = ../../namespace::*)]') |
        ForEach-Object -Begin { $result = [Dictionary[string, string]]::new() }  -Process {
            [string] $prefix = $_.LocalName
            if ($prefix -eq 'xmlns') { $prefix = $DefaultPrefix }
            $result.Add($prefix, $_.Value) } -End { $result }
    } else {
        [System.Xml.XPath.Extensions]::XPathEvaluate($XNode, '//namespace::*[not(. = ../../namespace::*)]') |ForEach-Object -Begin { $result = [Dictionary[string, string]]::new() }  -Process {
            [string] $prefix = $_.Name.LocalName
            if ($prefix -eq 'xmlns') { $prefix = $DefaultPrefix }
            $result.Add($prefix, $_.Value) } -End { $result }
    }
}