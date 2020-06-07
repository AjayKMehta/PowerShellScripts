
filter ConvertTo-SID
{
    <#
    .SYNOPSIS
        Convert user or computer account name to SID
    .DESCRIPTION
        Convert user or computer account name to SID
    .PARAMETER Account
        One or more account names to convert
    .EXAMPLE
        ConvertTo-SID $env:USERNAME
    .LINK
        http://msdn.microsoft.com/en-us/library/ftx85f8x%28v=vs.85%29.aspx
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$AccountName
    )

    foreach($id in $AccountName)
    {
        try
        {
            $account = New-Object System.Security.Principal.NTAccount($id)
            $name = ($account.Translate([System.Security.Principal.SecurityIdentifier]) ).Value
        }
        catch
        {
            $PSCmdlet.WriteError("$id is not a valid account or could not be identified")
            $name = $null
        }
        $name
    }
}