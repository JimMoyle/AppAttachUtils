. .\Convert-MSIXToAppAttach.ps1
. .\Move-MsixPackage.ps1
. .\Read-XmlManifest.ps1
. .\Mount-FslDisk.ps1
. .\Dismount-FslDisk.ps1
. .\Test-AppAttachManifest.ps1

#$files = Get-ChildItem "D:\App Attach Packages\Mozilla.MozillaFirefox\102.0.0.0\vhdx\Firefox Setup 102.0.vhdx" -File 

$files = Get-ChildItem "D:\MSIX Packages" -File -Recurse

$files = Get-ChildItem  "D:\App Attach Packages" -File -Recurse -Filter "*.vhdx"

#$files | Convert-MSIXToAppAttach -Type 'cim','vhdx' -PassThru

#Get-ChildItem C:\Users\jimoyle\Downloads\*.msix* -File | Move-MsixPackage

#$result = $files | Read-XmlManifest

$result = $files | Test-AppAttachManifest

$result