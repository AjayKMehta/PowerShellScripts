using namespace System.Management.Automation
using namespace Microsoft.PowerShell.Commands
using namespace System.IO

class ValidatePathExistsAttribute : ValidateArgumentsAttribute {
    [TestPathType] $PathType = 'Any'

    [void] Validate([object] $Path, [EngineIntrinsics] $EngineIntrinsics) {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            throw [System.ArgumentNullException]::new()
        }
        if (-not (Test-Path -Path $Path -PathType $this.PathType)) {
            switch ($this.PathType) {
                'Container' {
                    throw [DirectoryNotFoundException]::new("Unable to find the specified folder: $Path")
                }
                'Leaf' {
                    throw [FileNotFoundException]::new("Unable to find the specified file: $Path")
                }
                default {
                    throw [IOException]::new("Unable to find the specified path: $Path")
                }
            }
        }
    }
}
