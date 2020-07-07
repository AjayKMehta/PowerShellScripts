using namespace System.IO
function New-FileSystemWatcher {
    <#
    .SYNOPSIS
        Helper function for creating dynamic parameters.
    .DESCRIPTION
        Helper function for creating dynamic parameters.
    .NOTES
        The FileSystemWatcher will not watch the specified directory until the Path property has been set and EnableRaisingEvents is true.
    .EXAMPLE
        $fsw = New-FileSystemWatcher 'C:\temp' -Enable -Recurse
        $fsw.NotifyFilter += 'LastAccess'
        $fsw

        $defaultAction = {
            $name = $eventArgs.Name
            $item = if ((Get-Item $eventArgs.FullPath) -is [IO.FileInfo]) {
                'file'
            } else {
                'folder'
            }


            $changeType = $eventArgs.ChangeType
            $time = $event.TimeGenerated
            Write-Host "The $item .\$name was $changeType at $time."
        }

        $renameAction = {
            $name = $eventArgs.Name
            # $fullName = $eventArgs.FullPath
            $oldName = $eventArgs.OldName

            $item = if ((Get-Item $eventArgs.OldFullPath) -is [IO.FileInfo]) {
                'file'
            } else {
                'folder'
            }

            $changeType = $eventArgs.ChangeType
            $time = $event.TimeGenerated
            Write-Host "The $item .\$oldName was renamed to .\$name at $time."
        }

        Register-ObjectEvent $fsw 'Renamed' -Action $renameAction

        foreach ($event in 'Changed', 'Created', 'Deleted') {
            Register-ObjectEvent $fsw $event -Action $defaultAction -MaxTriggerCount 2
        }

    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=netcore-3.1
    #>
    [OutputType([System.IO.FileSystemWatcher])]
    param
    (
        [ValidatePathExists()]
        [Parameter(Mandatory = $true, Position = 0)]
        # Path of directory to watch
        [string] $Path,

        [Parameter(Mandatory = $false, Position = 1)]
        # Determines files being monitored in Path
        [string] $Filter = '*.*',

        [Parameter(Mandatory = $false)]
        # Types of changes to watch for
        [NotifyFilters] $NotifyFilter = [NotifyFilters]::LastWrite -bor [NotifyFilters]::FileName -bor [NotifyFilters]::DirectoryName,

        # If set, enable events.
        [switch] $Enable,

        [switch] $Recurse,

        [Parameter(Mandatory = $false)]
        # Size of the internal buffer. Defaults to 8192 (8KB).
        [int] $InternalBufferSize = 8192
    )
    'Recurse', 'Enable' | ForEach-Object { $null = $PSBoundParameters.Remove($_) }
    $PSBoundParameters.Add('IncludeSubDirectories', $Recurse)
    $fsw = New-Object System.IO.FileSystemWatcher -Property $PSBoundParameters
    $fsw.EnableRaisingEvents = $Enable
    $fsw
}
