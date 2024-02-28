#requires -RunAsAdministrator

$packagePath = 'Z:\AppAttachPackages' # if you change this remember to add the param to the function to override the defaults.

if (-not (Test-Path $packagePath)) {
    Write-Error 'connect to Azure Files first'
    return
}

$Private = @( Get-ChildItem -Path Functions\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in $Private) {
    Try {
        Write-Output "Importing $($Import.FullName)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

import-module "C:\Az.DesktopVirtualization\3.4.4\Az.DesktopVirtualization.psd1"

$allAppsFile = & Functions\WorkingDir\Get-WPMRestAll.ps1

$a = Import-Csv $allAppsFile

$msixResult = $a | ForEach-Object -Parallel {
    . .\Functions\Private\Get-WPMRestApp.ps1
    
   $_ | Get-WPMRestApp
} -ThrottleLimit 16

$msixAppsFile = Join-Path '.\results' ((get-date -Format FileDateTime).Substring(0, 13) + '-MsixApps.csv')

$msixResult | Export-Csv  $msixAppsFile -Force

$64BitMsixAppsFile = (get-date -Format FileDateTime).Substring(0, 13) + '-x64MsixApps.csv'

Import-Csv $msixAppsFile | Where-Object {$_.architecture -eq 'x64'} | Export-Csv (Join-Path '.\results' $64BitMsixAppsFile) -Force

Get-MSIXPackages -ListPath (Join-Path '.\results' $64BitMsixAppsFile) -PassThru -DestPath D:\MSIXPackages

$files = Get-ChildItem "D:\MSIXPackages" -File -Recurse

$files | Convert-MSIXToAppAttach -Type 'cim','vhdx' -PassThru

Sync-PackagesToAzure -PassThru