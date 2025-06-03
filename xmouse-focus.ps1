# Adapted from https://superuser.com/a/1209478
Param(
    #[int]$enable = 1
    [switch]$disable
)

$signature = @"
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, UIntPtr pvParam, uint fWinIni);
"@
$systemParamInfo = Add-Type -memberDefinition $signature -Name SloppyFocusMouse -passThru
$newVal = [UintPtr]::new($disable ? 0 : 1) # use 1 to turn on, 0 to turn off
$systemParamInfo::SystemParametersInfo(0x1001, 0, $newVal, 2)
