$wgs = winget search -q `"`"

$appMatch = "(.+)\s+(\S+)\s+(\S+)\s+winget$"

$appList = foreach ($app in $wgs) {
    #$app -match $appMatch 
    if ( $app -match $appMatch ) {
        $appInfo = $Matches

        $output = [PSCustomObject]@{
            Name = $appInfo[1].Trim()
            Id = $appInfo[2]
            Version = $appInfo[3]
        }
        Write-Output $output
    }
}

$appList | Export-Csv .\Results\Applist.csv -NoClobber