using namespace System.Collections.Generic

filter Get-Namespace {
    <#
    .SYNOPSIS
        Returns a dictionary whose key is the prefix and value is the URI for each namespace for an XML node.
    .DESCRIPTION
        Returns a dictionary whose key is the prefix and value is the URI for each namespace for an XML node.
    .PARAMETER Node
        XML node for which you wish to get defined namespaces.
    .PARAMETER XNode
        Node for which you wish to get defined namespaces.
    .PARAMETER DefaultPrefix
        Prefix for default namespace(s). Also, used for cases where duplicate prefixes pointing to different namespaces. Defaults to 'ns'.
    .PARAMETER Unique
        If set, do not add multiple prefixes for same namespace.
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

        Get-Namespace -XNode $xDoc
    .LINK
        http://stackoverflow.com/questions/767541/how-i-can-list-out-all-the-namespace-in-xml
    #>
    [Outputtype([System.Collections.Generic.Dictionary[string, string]])]
    [CmdletBinding(DefaultParameterSetName = 'Node', PositionalBinding = $false)]
    param
    (
        [ValidateNotNull()]
        [Parameter(Mandatory = $true, ParameterSetName = 'Node', ValueFromPipeline = $true)]
        [System.Xml.XmlNode] $Node,

        [ValidateNotNull()]
        [Parameter(Mandatory = $true, ParameterSetName = 'XNode', ValueFromPipeline = $true)]
        [System.Xml.Linq.XNode] $XNode,

        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory = $false, Position = 0)]
        [Alias('Prefix')]
        [string] $DefaultPrefix = 'ns',

        [switch] $Unique
    )
    $nsPrefixes =
    if ($PSCmdlet.ParameterSetName -eq 'Node') {
        $Node.SelectNodes('//namespace::*[not(. = ../../namespace::*)]') |
        Select-Object LocalName, Value
    } else {
        [System.Xml.XPath.Extensions]::XPathEvaluate($XNode, '//namespace::*[not(. = ../../namespace::*)]') |
        Select-Object Value -ExpandProperty Name
    }

    $result = [Dictionary[string, string]]::new()
    [int] $ctr = 0

    foreach ($nsPrefix in $nsPrefixes) {
        [string] $prefix = $nsPrefix.LocalName
        [string] $uri = $nsPrefix.Value
        if (!$Unique -or !$result.ContainsValue($uri)) {
            if (($prefix -eq 'xmlns') -or (($prefix -ne 'xml') -and $result.ContainsKey($prefix))) {
                $prefix = "$DefaultPrefix$(if($ctr){$ctr})"
                $ctr++
            }
            $result.Add($prefix, $uri)
        }
    }
    $result
}