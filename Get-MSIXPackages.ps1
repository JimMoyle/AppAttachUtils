function Get-MSIXPackages {
    [CmdletBinding()]

    Param (
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [System.String]$ListPath = 'C:\Users\jimoyle\OneDrive - Microsoft\Documents\PoShCode\Winget analysis\result.csv',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$DestPath = 'D:\MSIXPackages',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$PassThru,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$NoDownload
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        $packageList = Import-Csv $ListPath

        foreach ($package in $packageList) {
            if ($package.DownloadUrl -like "*.msix*" -or $package.DownloadUrl -like "*.appx*" -or $package.type -eq "MSIX") {

                if ($package.Id -like "Canonical.Ubuntu*" -or $package.Id -like "Debian.Debian*" ){
                    Continue
                }

                If ($PassThru) {
                    Write-Output $package
                }

                If ($NoDownload){
                    Continue
                }

                $fileName = $package.DownloadUrl.split('/') | Select-Object -Last 1

                $destId = Join-Path $DestPath $package.Id
                $destVer = Join-Path $destId $package.Version

                if (-not (Test-Path $destVer)){
                    New-Item -ItemType Directory $destVer | Out-Null
                }

                $destFile = Join-Path $destVer $fileName

                if (-not (Test-Path $destFile)){
                    try {
                        Invoke-WebRequest -Uri $package.DownloadUrl -OutFile $destFile -ErrorAction Stop
                    }
                    catch {
                        Remove-Item $destVer
                        if ((Get-ChildItem -Recurse $destId -File | Measure-Object | Select-Object -ExpandProperty Count) -eq 0){
                            Remove-Item $destId
                        }
                    }
                }

            }
        }

        
    } # process
    end {} # end
}  #function Get-MSIXPackages