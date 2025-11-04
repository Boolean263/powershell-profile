# This file (Documents\PowerShell\profile.ps1)
# is the Profile ( = script run when PowerShell Starts)
# for CurrentUserAllHosts in PowerShell version 7.
# (Version 5 uses Documents\WindowsPowerShell instead.)
# It will be called before (and thus overridden by)
# the profile for CurrentUserCurrentHost.
# To see profiles available in PS:
#
#    $Profile | Select-Object *
#
# I'm not clear what a "Host" is, but it seems to be a context
# for running PowerShell within, since the docs state Visual Studio
# can have its own host.
#
# See about_Profiles for more info:
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
#
# NOTE: If you use Windows Explorer to move your Documents folder
# out of $HOME, then PowerShell will still look for its
# CurrentUser profiles in the PowerShell subdirectory of the new
# Documents folder. However, since that path is no longer
# $HOME\Documents\PowerShell, a statement like this might not work:
#
#    Import-Module "$HOME\Documents\PowerShell\Modules\EnvPaths.psm1"
#
# I worked around that by moving EnvPaths.psm1 to a location where
# PowerShell would automatically import it.
# See Modules\README.md.txt for details.

# Create my own alias for PowerShell's version of "which"
New-Alias -name which -Value Get-Command

# Create a function to do a "touch" of a file
Function touch {
    # I can't get this to create an optional -NewDate parameter :(
    #Param(
    #    [Parameter(Mandatory=$false)]
    #    [System.DateTime]$NewDate = (Get-Date)
    #)
    # Workaround for now
    $NewDate = Get-Date

    ForEach-Object ($args) {
        If (Test-Path -Path $_) {
            (Get-Item $_).LastWriteTime = $NewDate
        }
        Else {
            New-Item -Path $_ -ItemType File
        }
    }
}
