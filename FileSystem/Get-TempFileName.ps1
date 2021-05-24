using namespace System.IO
function Get-TempFileName {
    param
    (
        [switch] $IncludePath
    )
    [string] $result = [Path]::GetTempFileName()
    if (!$IncludePath) { $result = $result.Replace([Path]::GetTempPath(), '') }
    $result
}
