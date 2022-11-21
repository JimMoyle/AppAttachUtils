#Get-AppAttachRecentPath

$Path = 'Y:\Mozilla.MozillaFirefox'

$versionFolders = Get-ChildItem -Path $Path -Directory

$versions =  foreach ($ver in $versionFolders.Name){
    [version]$ver
}

$mostRecent = $versions | Sort-Object -Descending | Select-Object -First 1

$diskPath = Join-Path $Path $mostRecent.ToString()

$splatGetChildItem = @{
    Path = $diskPath
    Recurse = $true
    File = $true
}

$cimPath = Get-ChildItem @splatGetChildItem -Filter *.cim
$vhdxPath = Get-ChildItem @splatGetChildItem -Filter *.vhdx