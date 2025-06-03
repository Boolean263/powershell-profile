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
