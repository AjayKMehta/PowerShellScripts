function Run-WithEnvVariable {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [hashtable] $EnvValues,
        [switch] $Clobber,
        [ScriptBlock] $Cmd
    )
    end {
        [Hashtable] $prevValues = @{}
        foreach ($entry in $EnvValues.GetEnumerator()) {
            [string] $name = $entry.Key
            $value = $entry.Value

            $existing = [Environment]::GetEnvironmentVariable($name, 'Process')
            if ($existing -and $Clobber) {
                $prevValues.Add($name, $existing)
            }
            if ($Clobber -or (-not $existing)) {
                [Environment]::SetEnvironmentVariable($name, $value, 'Process')
            }
        }
        . $Cmd
    }
    clean {
        foreach ($entry in $EnvValues.GetEnumerator()) {
            [string] $name = $entry.Key
            [Environment]::SetEnvironmentVariable($name, $null, 'Process')
        }

        foreach ($entry in $prevValues.GetEnumerator()) {
            [string] $name = $entry.Key
            $value = $entry.Value
            [Environment]::SetEnvironmentVariable($name, $value, 'Process')
        }
    }
}
