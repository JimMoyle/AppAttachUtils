Set-Content result.csv -Value 'Name,Id,Version,Publisher,Type,DownloadUrl,MSIX'
$packages = Import-Csv .\Results\Applist.csv
#$packages = $packages | Select-Object -First 50
$packages | ForEach-Object {
    if (-not($_.Id)) {
        return
    }
    $name = $_.Name
    $id = $_.Id
    $ver = $_.Version

    $wingetShow = winget.exe show $id

    $DownloadUrl = ($wingetShow | Where-Object { $_ -Like "*Download Url:*" }).split("//")[1].Trim()

    $out = [PSCustomObject]@{
        Name        = $name
        Id          = $id
        Version     = $ver
        Publisher   = ($wingetShow | Where-Object { $_ -Like "Publisher:*" }).split(":")[1].Trim()
        Type        = ($wingetShow | Where-Object { $_ -Like "*Type:*" }).split(":")[1].Trim()
        DownloadUrl = $DownloadUrl
    }
    $out | Export-Csv 'result.csv' -NoClobber -Append
}