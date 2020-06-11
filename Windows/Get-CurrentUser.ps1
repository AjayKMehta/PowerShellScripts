using namespace System.Security.Principal

function Get-CurrentUser
{
    [OutputType([System.Security.Principal.WindowsPrincipal])]
    param()
    [WindowsPrincipal]::new(([WindowsIdentity]::GetCurrent()))
}