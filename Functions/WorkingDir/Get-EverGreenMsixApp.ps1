$appList = 'MicrosoftWindowsPackageManagerClient', 'DevToys', 'ScreenToGif', 'MozillaFirefox'

$appDetail = foreach ($app in $appList) {
    Find-EvergreenApp $app | Get-EvergreenApp -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Where-Object {$_.Type -eq 'msix' -and $_.Architecture -eq 'x64'}
}

$appDetail | Get-MSIXPackages