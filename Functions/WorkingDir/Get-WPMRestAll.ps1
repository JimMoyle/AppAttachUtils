$uri = 'https://pkgmgr-wgrest-pme.azurefd.net/api/manifestSearch'

$body = [PSCustomObject]@{
    Query = [PSCustomObject]@{
        KeyWord   = ''
        MatchType = 'Substring'
    }
}

$json = $body | ConvertTo-Json

$result = Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType 'application/json'

$continue = $true
$appList = While ($continue -ne $false) {
    
    foreach ($package in $result.Data) {
        $packageDetail = [PSCustomObject]@{
            PackageName       = $package.PackageName
            PackageIdentifier = $package.PackageIdentifier
            Publisher         = $package.Publisher
        }
        Write-Output $packageDetail
    }

    if ($null -eq $result.ContinuationToken) {
        $continue = $false
    }
    else {
        $header = @{
            ContinuationToken = $result.ContinuationToken
        }
    
        $result = Invoke-RestMethod -Method Post -Uri $uri -Body $json -ContentType 'application/json' -Header $header
    }
}

$filename = (get-date -Format FileDateTime).Substring(0, 13) + '-FullAppList.csv'

$appList | Export-Csv (Join-Path '.\results' $filename) -Force

Write-Output (Join-Path '.\results' $filename)