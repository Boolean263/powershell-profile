# Based on https://gist.github.com/jaw/4d1d858b87a5c208fbe42fd4d4aa97a4
# and heavily modified to allow multiple paths in one operation in most cases.
#
#  How to use
#
#  First, you need to import the script:
#  > Import-Module -Name "C:\Your\Path\to\EnvPaths.psm1"
#
#  Add C:\Foo and D:\bar as the first paths in the current session
#  (goes away when you log out / close the window):
#  > Add-EnvPath -First "C:\Foo", "D:\bar"
#
#  Add C:\Foo and D:\bar as the first paths in the machine path (all users):
#  > Add-EnvPath -First -Paths "C:\Foo", "D:\bar" -Container Machine
#
#  Remove any path matching *Foo* from the system paths for all users:
#  > Remove-EnvPath -Path *Foo* -Container Machine
#
#  Look for the existance of a wildcard path:
#  > $present = Find-EnvPath -Path "*CMake\bin*" -Container Machine
#  > if ([bool]$present) { Write-Host "found cmake binary path" }

# Helper function
function _container_type {
    param(
        [ValidateSet('Machine', 'User', 'Session', 'Process')]
        [string] $Container
    )

    $containerMapping = @{
        Machine = [EnvironmentVariableTarget]::Machine
        User = [EnvironmentVariableTarget]::User
        Process = [EnvironmentVariableTarget]::Process
        Session = [EnvironmentVariableTarget]::Process
    }
    return $containerMapping[$Container]
}

function Add-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string[]] $Path,

        [Parameter(Mandatory=$false)]
        [string] $PathVar = 'Path',

        [Parameter(Mandatory=$false)]
        [string] $PathSep = ';',

        [switch]$First,

        [ValidateSet('Machine', 'User', 'Session', 'Process')]
        [string] $Container = 'Session'
    )

    $containerType = _container_type $Container

    $envPaths = [Environment]::GetEnvironmentVariable($PathVar, $containerType) -split $PathSep
    $wantPaths = @($Path | where { $_ -and $envPaths -notContains $_ })

    if ([bool]$wantPaths) {
        if ($First) {
            $envPaths = @($wantPaths) + @($envPaths) | where { $_ }
        }
        else {
            $envPaths = @($envPaths) + @($wantPaths) | where { $_ }
        }
        [Environment]::SetEnvironmentVariable($PathVar, $envPaths -join $PathSep, $containerType)
    }
}

function Remove-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string[]] $Path,

        [Parameter(Mandatory=$false)]
        [string] $PathVar = 'Path',

        [Parameter(Mandatory=$false)]
        [string] $PathSep = ';',

        [ValidateSet('Machine', 'User', 'Session', 'Process')]
        [string] $Container = 'Session'
    )

    $containerType = _container_type $Container

    $envPaths = [Environment]::GetEnvironmentVariable($PathVar, $containerType) -split $PathSep | where { $_ }

    foreach ($dropPath in $Path) {
        $envPaths = @($envPaths) | where { $_ -and $_ -notlike $dropPath }
    }

    [Environment]::SetEnvironmentVariable($PathVar, $envPaths -join $PathSep, $containerType)
}

function Get-EnvPath {
    param(
        [Parameter(Mandatory=$false)]
        [string] $PathVar = 'Path',

        [Parameter(Mandatory=$false)]
        [string] $PathSep = ';',

        [ValidateSet('Machine', 'User', 'Session', 'Process')]
        [string] $Container = 'Session'
    )

    $containerType = _container_type $Container

    [Environment]::GetEnvironmentVariable($PathVar, $containerType) -split $PathSep |
        where { $_ }
}

# returns True when the path is defined in the set of paths
function Find-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [Parameter(Mandatory=$false)]
        [string] $PathVar = 'Path',

        [Parameter(Mandatory=$false)]
        [string] $PathSep = ';',

        [ValidateSet('Machine', 'User', 'Session', 'Process')]
        [string] $Container = 'Session'
    )

    $containerType = _container_type $Container

    $envPaths = [Environment]::GetEnvironmentVariable($PathVar, $containerType) -split $PathSep
    # filter out the possible wildcard path
    $envPaths = $envPaths | where { $_ -and $_ -like $Path }
    return $envPaths -ne $null
}

Export-ModuleMember -Function Add-EnvPath, Remove-EnvPath, Get-EnvPath, Find-EnvPath
