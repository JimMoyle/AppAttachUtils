$Private = @( Get-ChildItem -Path Functions\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in $Private) {
    Try {
        Write-Verbose "Importing $($Import.FullName)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

#. .\Functions\Public\Test-MsixToAppAttach.ps1

#$vhdx = Read-XmlManifest "D:\AppAttachPackages\simplenote\2.21.0.0\vhdx\Simplenote-win-2.21.0-x64.vhdx"

#$cim = Read-XmlManifest -Path "D:\AppAttachPackages\simplenote\2.21.0.0\cim\Simplenote-win-2.21.0-x64.cim"



#$appx = Read-XmlManifest "D:\MSIXPackages\simplenote\2.21.0.0\Simplenote-win-2.21.0-x64.appx"

#$appx

#$result = Test-MsixToAppAttach -NoDownload -SyncOption Mirror

#$result | Export-Csv Results\final.csv

#>
<#
$a = Import-Csv Results\20230707T1107-FullAppList.csv

$msixResult = $a | ForEach-Object -Parallel {
    . .\Functions\Private\Get-WPMRestApp.ps1
   $_ | Get-WPMRestApp
} -ThrottleLimit 16

$filename = (get-date -Format FileDateTime).Substring(0, 13) + '-MsixApps.csv'

$msixResult | Export-Csv (Join-Path '.\results' $filename) -Force
#>


$filename = (get-date -Format FileDateTime).Substring(0, 13) + '-x64MsixApps.csv'

Import-Csv Results\20230512T1406-MsixApps.csv | Where-Object {$_.architecture -eq 'x64'} | Export-Csv (Join-Path '.\results' $filename) -Force
#>

#Get-MSIXPackages -ListPath Results\20230512T1409-x64MsixApps.csv -PassThru -DestPath D:\MSIXPackages

#$files = Get-ChildItem "D:\MSIXPackages\Microsoft.WindowsTerminalPreview\1.15.2282.0\CascadiaPackage_1.15.2282.0_x64.msix" -File 

#$files = Get-ChildItem "D:\MSIXPackages" -File -Recurse

#$files = Get-ChildItem  "D:\App Attach Packages" -File -Recurse -Filter "*.vhdx"

#$files | Convert-MSIXToAppAttach -Type 'cim','vhdx' -PassThru

#Get-ChildItem "C:\Users\jimoyle\Downloads\CascadiaPackage_1.15.2282.0_x64.msix" -File | Move-MsixPackage

#$result = $files | Read-XmlManifest

#$result = $files | Test-AppAttachManifest

#$icons = gci X:\apps\Mozilla.MozillaFirefox_103.0.1.0_x64__gmpnhwe7bv608\Assets | Get-IconInfo

#$icons | Sort-Object -Property Area -Descending | select -First 1

#Test-AppAttachManifest 'D:\AppAttachPackages\Mozilla.MozillaFirefox\104.0.0.0\cim\Firefox Setup 104.0.cim'
#Sync-PackagesToAzure -Verbose -PassThru

#Expand-MsixDiskImage -Url 'https://avdtoolsmsix.file.core.windows.net/appattach/AppAttachPackages/Mozilla.MozillaFirefox/107.0.0.0/vhdx/Firefox%20Setup%20107.0.vhdx' -HostPoolName 'Win10MsixTest' -ResourceGroupName 'AVDPermanent'