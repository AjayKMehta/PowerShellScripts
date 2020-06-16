using namespace System.Security.AccessControl

function Get-FSEffectiveAccess {
    <#
    .SYNOPSIS
        Returns unique set of FileSystemRights and additional properties indicating whether 1) a right is inherited or not and 2) a right is allowed or denied.
    .DESCRIPTION
        Returns unique set of FileSystemRights and additional properties indicating whether 1) a right is inherited or not and 2) a right is allowed or denied.
        If FileSystemRights are compound values and NoCompound switch is set, then they will get broken down into individual values, e.g. Write = WriteData + WriteExtendedAttributes + AppendData + WriteAttributes.
        In order to determine if a FileSystemRight is allowed/denied, code will first look at local (IsInherited = $false) rules then rules that specify Deny before Allow.
    .PARAMETER Path
        The path whose access you need to check.
    .PARAMETER Principal
        The principal for whom you need to check access.
    .PARAMETER AsHashTable
        If specified, result is a hashtable with key = FileSystemRights and value = boolean indicating whether a right is allowed or denied.
    .PARAMETER NoCompound
        If set, compound FileSystemRights will get broken down into their underlying values.
    .NOTES
        This needs to be tested more rigorously. Use at your own risk!
    .EXAMPLE
        "C:\temp" | Get-FSEffectiveAccess
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param
    (
        [SupportsWildCards()]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Path,
        [Parameter(Mandatory = $false, Position = 0)]
        [System.Security.Principal.WindowsPrincipal] $Principal = (Get-CurrentUser),
        [switch] $AsHashTable,
        [switch] $NoCompound
    )

    process {
        $result = Get-FSAccessRule -Path $Path -Principal $Principal |
        ForEach-Object {
            $show = if ($NoCompound) { 'NoCompound' } else { 'Compound' }
            $flags = Get-Flag $_.FileSystemRights -Show $show

            # Flatten structure
            foreach ($flag in $flags) {
                New-Object psobject -Property @{
                    "FileSystemRights"  = $flag
                    "AccessControlType" = $_.AccessControlType
                    "IsInherited"       = $_.IsInherited
                }
            }
        } | # Non-inherited rules take precedence over inherited rules and Deny over Allow
        Sort-Object FileSystemRights, IsInherited, @{Expression = { $_.AccessControlType }; Ascending = $false } -Unique |
        Group-Object FileSystemRights |
        ForEach-Object { $_.Group | Select-Object -First 1 }
        if ($result -and $AsHashTable) {
            $ht = @{}
            $result.ForEach( { $ht[$_.FileSystemRights] = ($_.AccessControlType -eq [AccessControlType]::Allow) })
            $result = $ht
        }
        $result
    }
}

