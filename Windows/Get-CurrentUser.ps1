using namespace System.Security.Principal

function Get-CurrentUser
{
    [OutputType([WindowsPrincipal])]
    param()
    [WindowsPrincipal]::new(([WindowsIdentity]::GetCurrent()))
}