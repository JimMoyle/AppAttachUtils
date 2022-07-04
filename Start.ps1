. .\Convert-MSIXToAppAttach.ps1

. .\Move-MsixPackage.ps1

. .\Read-XmlManifest.ps1

$files = Get-ChildItem "D:\MSIX Packages\Mozilla.MozillaFirefox\102.0.0.0\Firefox Setup 102.0.msix" -File 

#$files = Get-ChildItem "D:\MSIX Packages" -File -Recurse

#$files | Convert-MSIXToAppAttach -Type 'cim','vhdx' -PassThru

#Get-ChildItem C:\Users\jimoyle\Downloads\*.msix* -File | Move-MsixPackage

$result = $files | Read-XmlManifest

$result