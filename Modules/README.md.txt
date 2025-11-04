# PowerShell Modules

PowerShell will automatically load modules from any directory listed in `$Env:PSModulePath`
as long as these conditions are met:

1. The module is in a *subdirectory* of such a directory
2. The subdirectory and the module filename have the same base name
3. The module filename ends in `.psm1`

So, assuming that `$Profile.CurrentUserAllHosts` is in its default location
of `$HOME\Documents\PowerShell`, PowerShell would automatically load `Modules\EnvPaths\EnvPaths.psm1`
but *not* `Modules\EnvPaths.psm1`; I had import the ltter manually using `Import-Module`.

To see all modules that are availale in `$Env:PSModulePath`, use this command:

    Get-Module -ListAvailable

# Future Durdling

For my own helper modules, it seems a bit much to have a separate directory *and* file
for each one. In the future I'll probbly create a `Modules\Boolean263\Boolean263.psm1`
which imports other `.psm1` files that exist in its directory.

# More Information

* [about\_Modules](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules)
* [How to Write a PowerShell Script Module](https://learn.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-script-module)
* Stack Overflow: [What's the best way to determine the location of the current PowerShell script?](https://stackoverflow.com/q/5466329)
