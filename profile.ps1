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
# out of $USERPROFILE, then PowerShell will look for its
# CurrentUser profiles in the PowerShell subdirectory of the new
# Documents folder. However, since that path is no longer
# $USERPROFILE\Documents\PowerShell, a statement like this might not work:
#
#    Import-Module "$env:USERPROFILE\Documents\PowerShell\Modules\EnvPaths.psm1"
#
# Nominally, this code would accommodate a moved Documents folder,
# but it doesn't work on a test system, since the GetFolderPath call
# returns an empty string:
#
#    Import-Module [Environment]::GetFolderPath("MyDocuments") + "\PowerShell\Modules\EnvPaths.psm1"
#
# Something like this seems more likely to work (note extra parentheses):
#
#    Import-Module ((Get-Item $profile.CurrentUserAllHosts).Directory.ToString() + "\Modules\EnvPaths.psm1")
#
# But I worked around it by moving EnvPaths.psm1 to a location where
# PowerShell would automatically import it.
# See Modules\README.md.txt for details.

# Add my user Python virtual environment, if it exists.
# I'm putting it in my $USERPROFILE folder because of the weirdness
# mentioned above around the Documents folder, and
# also because I use some systems where Documents is on a slow network drive.
& {
    $MyPyPath = "$env:USERPROFILE\PSPyVEnv\Scripts"
    if (Test-Path -Path $myPyPath) {
        Add-EnvPath -First $myPyPath
    }
}

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

# Environment variables that affect programs.
# Assumes XDG_CONFIG_HOME etc. are configured in my Windows environment
# (which they are on systems I own).
# NB. This duplicates some of the configuration in my `~/.config/environment.d`
# so maybe eventually I'll see if there's a way to parse those files here.
$env:RIPGREP_CONFIG_PATH = "$env:XDG_CONFIG_HOME\ripgreprc"
