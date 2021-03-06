filter Get-NamespaceManager {
    <#
    .SYNOPSIS
        Returns an XmlNamespaceManager for an XML document.
    .DESCRIPTION
        Returns an XmlNameSpaceManager for an XML document. It does this by parsing all nodes with namespace prefixes.
        If a namespace is mapped to more than one prefix, it will only use the first if -Unique is set.
        If a prefix is used more than once in a document, it will only use the first one and create dummy prefixes for subsequent occurences.
    .PARAMETER XmlDocument
        The document for which you need a namespace manager.
    .PARAMETER DefaultPrefix
        Prefix for default namespace(s). Also, used for cases where duplicate prefixes pointing to different namespaces. Defaults to 'ns'.
    .PARAMETER Unique
        If set, do not add multiple prefixes for same namespace.
    .OUTPUTS
        Xml.XmlNamespaceManager
    .EXAMPLE
        $xmlDoc = [xml](@'
        <w xmlns:a="mynamespace">
          <a:x>
            <y xmlns:a="myOthernamespace">
              <z xmlns="mynamespace"/>
              <b:z xmlns:b="mynamespace"/>
              <z xmlns="myOthernamespace2"/>
              <b:z xmlns:b="myOthernamespace"/>
            </y>
          </a:x>
        </w>
        '@)

        $nsm = Get-NamespaceManager $xmlDoc -Verbose
        $nsm.GetEnumerator() | % { $_,$nsm.LookupNamespace($_) }
    .EXAMPLE
        # This uses same $xmlDoc as previous example.
        $xmlDoc | Get-NameSpaceManager -Prefix 'ns'
    #>
    [OutputType([Xml.XmlNamespaceManager])]
    [Cmdletbinding()]
    param
    (
        [ValidateNotNull()]
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Alias('Xml')]
        [Xml] $XmlDocument,

        [ValidateNotNullorEmpty()]
        [Parameter(Mandatory = $false, Position = 1)]
        [Alias('Prefix')]
        [string] $DefaultPrefix = 'ns',

        [switch] $Unique
    )

    [Xml.XmlNamespaceManager] $xmlNsManager = [Xml.XmlNamespaceManager]::new($XmlDocument.NameTable)
    [int] $ctr = 0;

    $XmlDocument.SelectNodes('//namespace::*[not(. = ../../namespace::*)]') |
    ForEach-Object {
        $prefix, $nsURI = $_.LocalName, $_.Value ;
        [bool] $add = $true

        if ($Unique) {
            [string] $p = $xmlNsManager.LookupPrefix($nsURI)
            if ($p -and ($p -ne $prefix)) {
                Write-Verbose "Namespace '$nsURI' already mapped to prefix '$p'. Skip mapping to '$prefix'."

                $add = $false
            }
        }
        if ($add) {
            if (($prefix -eq 'xmlns') -or (($prefix -ne 'xml') -and $xmlNsManager.HasNamespace($prefix))) {
                $prefix = "$DefaultPrefix$(if($ctr){$ctr})"
                $ctr++
            }
            $xmlNsManager.AddNamespace($prefix, $nsURI)
        }
    }

    # Need to put the comma before the variable name so that PowerShell doesn't convert it into an Object[].
    , $xmlNsManager
}
