. .\Convert-MSIXToAppAttach.ps1

$files = Get-ChildItem "D:\MSIX Packages\Mozilla.MozillaFirefox\102.0.0.0\Firefox Setup 102.0.msix" -File 

#$files = Get-ChildItem "D:\MSIX Packages" -File -Recurse

$files | Convert-MSIXToAppAttach -Type 'cim','vhdx'