function Get-PathEnv {
    <#
    .SYNOPSIS
        Get paths specified in input PATH environment variable or string.
    .DESCRIPTION
        Get paths specified in PATH environment variable or string.
    .PARAMETER Target
        The environment (Machine, Process, User) whose path variable you wish to inspect.
    .PARAMETER Path
        The string whom you wish to split into its component paths.
    .PARAMETER NoTrim
        If set, do not trim returned values.
    .NOTES
        This will automatically trim paths returned unless NoTrim is set.
        If used with Path as opposed to Target, environment variables will not
        be replaced by their corresponding values in returned results, e.g. it
        will not replace %TMP% with "C:\Users\$($env:UserName)\AppData\Local\Temp".
    .EXAMPLE
        Get-PathEnv -Path 'C:\temp; D:\git'
    .EXAMPLE
        Get-PathEnv -Path 'C:\temp; D:\git;"D:\temp\test;"'

        Output is:
        C:\temp
        D:\git
        D:\temp\test;
    .EXAMPLE
        Get-PathEnv -Path 'C:\temp;"D:\temp\test;";%AppData%\code'

        Output is:
        C:\temp
        D:\temp\test;
        %AppData%\code

        Notice how this does not replace %AppData% with its actual value!
    .EXAMPLE
        Get-PathEnv 'Machine' | Out-File C:\temp\path-test.txt -Encoding UTF8
    #>
    [CmdletBinding(DefaultParameterSetName = 'Target', PositionalBinding = $false)]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Target', Position = 0)]
        [Alias('Target')]
        [System.EnvironmentVariableTarget] $EnvTarget = [System.EnvironmentVariableTarget]::Process,

        [Parameter(Mandatory = $true, ParameterSetName = 'Path', ValueFromPipeline = $true)]
        [string] $Path,

        [Parameter(Mandatory = $false)]
        [switch] $NoTrim
    )
    begin {
        if ($PSCmdlet.ParameterSetName -eq 'Target') {
            $Path = [System.Environment]::GetEnvironmentVariable('PATH', $EnvTarget)
        }
        function get-val([string]$val) {
            if ($NoTrim) {
                $val
            } else {
                $val.Trim()
            }
        }
    }
    process {
        [int] $len = $Path.Length
        [int] $current = 0
        while ($current -lt $len - 1) {
            if ($Path[$current] -eq '"') {
                $end = $Path.IndexOf([char] '"', $current + 1)
                if ($end -eq -1 -or ($end -lt $len - 1 -and $Path[$end + 1] -ne ';')) {
                    throw 'Malformed text'
                }
                [string] $val = $Path.Substring($current + 1, $end - $current - 1)
                get-val $val
                $current = $end + 2
            } else {
                $end = $Path.IndexOf([char] ';', $current + 1)
                if ($end -eq -1) {
                    $end = $len
                }
                [string] $val = $Path.Substring($current, $end - $current).Trim()
                get-val $val
                $current = $end + 1
            }
        }
    }
}
