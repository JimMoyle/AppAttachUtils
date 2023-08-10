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


#& Functions\Private\Get-WPMRestAll.ps1


<#
$a = Import-Csv Results\20230810T1742-FullAppList.csv

$msixResult = $a | ForEach-Object -Parallel {
    . .\Functions\Private\Get-WPMRestApp.ps1
   $_ | Get-WPMRestApp
} -ThrottleLimit 16

$filename = (get-date -Format FileDateTime).Substring(0, 13) + '-MsixApps.csv'

$msixResult | Export-Csv (Join-Path '.\results' $filename) -Force
#>

<#
$filename = (get-date -Format FileDateTime).Substring(0, 13) + '-x64MsixApps.csv'

Import-Csv Results\20230512T1406-MsixApps.csv | Where-Object {$_.architecture -eq 'x64'} | Export-Csv (Join-Path '.\results' $filename) -Force
#>

#Get-MSIXPackages -ListPath (Join-Path '.\results' $filename) -PassThru -DestPath D:\MSIXPackages

$files = Get-ChildItem "D:\MSIXPackages" -File -Recurse

$files | Convert-MSIXToAppAttach -Type 'cim','vhdx' -PassThru

Sync-PackagesToAzure -PassThru