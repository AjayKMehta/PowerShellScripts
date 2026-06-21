using namespace System.Diagnostics.CodeAnalysis

[SuppressMessageAttribute('PSAvoidLongLines', Justification = 'Need for example code')]
param()

function Clear-VsCodeCache {
    <#
    .LINK
        https://stackoverflow.com/questions/67698176/error-loading-webview-error-could-not-register-service-workers-typeerror-fai
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ()

    [string] $root = "$env:APPDATA\Code"
    "$root\Cache", "$root\CachedData", "$root\CachedExtensions",
    "$root\CachedExtensionVSIXs", "$root\Code Cache" |
        Get-ChildItem -ErrorAction Ignore | Remove-Item -Recurse @PSBoundParameters
}
