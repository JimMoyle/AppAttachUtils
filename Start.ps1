. .\Convert-MSIXToAppAttach.ps1
. .\Move-MsixPackage.ps1
. .\Read-XmlManifest.ps1
. .\Mount-FslDisk.ps1
. .\Dismount-FslDisk.ps1
. .\Test-AppAttachManifest.ps1
. .\Get-MSIXPackages.ps1
. .\Sync-PackagesToAzure.ps1
. .\Get-IconInfo.ps1
# $files = Get-ChildItem "D:\MSIXPackages\Microsoft.WindowsTerminal\1.14.1962.0\CascadiaPackage_1.14.1962.0_x64.msix" -File 

#$files = Get-ChildItem "D:\MSIX Packages" -File -Recurse

#$files = Get-ChildItem  "D:\App Attach Packages" -File -Recurse -Filter "*.vhdx"

#$files | Convert-MSIXToAppAttach -Type 'cim','vhdx' -PassThru

#Get-ChildItem C:\Users\jimoyle\Downloads\*.msix* -File | Move-MsixPackage

#$result = $files | Read-XmlManifest

#$result = $files | Test-AppAttachManifest

#$result = Get-MSIXPackages -PassThru -NoDownload

#$token = Get-Content D:\GitHub\AppAttachUtils\SasToken.txt

#$result = Sync-PackagesToAzure -Token $token

#$result

#Move-MsixPackage "C:\Users\jimoyle\Downloads\Microsoft.WindowsTerminal_Win10_1.14.1962.0_8wekyb3d8bbwe.msixbundle"

$icons = gci X:\apps\Mozilla.MozillaFirefox_103.0.1.0_x64__gmpnhwe7bv608\Assets | Get-IconInfo

$icons | Sort-Object -Property Area -Descending | select -First 1