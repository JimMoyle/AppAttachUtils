function Get-MSIXPackages {
    [CmdletBinding()]

    Param (
        [Parameter(
            ParameterSetName = 'List',
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ListPath = 'C:\Users\jimoyle\OneDrive - Microsoft\Documents\PoShCode\Winget analysis\result.csv',

        [Parameter(
            ParameterSetName = 'Uri',
            ValueFromPipeline = $true,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [Alias('InstallerUrl')]
        [System.String[]]$Uri,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$DestPath = 'D:\MSIXPackages',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$PassThru
    )

    begin {
        . .\Read-XmlManifest.ps1
        Set-StrictMode -Version Latest
    } # begin
    process {
        #TODO download first to temp location from url, then move it to proper location
        switch ($PSCmdlet.ParameterSetName) {
            List { 
                $csvList = Import-Csv $ListPath
                $packageList = $csvList.InstallerUrl
            }
            Uri { $packageList = $Uri }
            Default {}
        }
       
        foreach ($package in $packageList) {

            if ($package -like "*Canonical*Ubuntu*" -or $package -like "*Debian*Debian*" -or $package -like "*whitewaterfoundry*fedora*" ) {
                Continue
            }

            $fileName = $package.split('/') | Select-Object -Last 1

            $destFile = Join-Path $env:TEMP $fileName

            if (-not (Test-Path $destFile)) {
                try {
                    Invoke-WebRequest -Uri $package -OutFile $destFile -ErrorAction Stop

                }
                catch {
                    Write-Error "Could not download from $package"
                    <#
                    Remove-Item $destVer
                    if ((Get-ChildItem -Recurse $destId -File | Measure-Object | Select-Object -ExpandProperty Count) -eq 0) {
                        Remove-Item $destId
                    }
                    #>
                    continue
                }
            }

            if ($package -notlike "*.msix*" -and $package -notlike "*.appx*" ) {
                continue
            }

            $manifest = Read-XmlManifest $destFile

            $version = $manifest.Identity.Version

            $name = $manifest.Identity.Name

            $destId = Join-Path $DestPath $name
            $destVer = Join-Path $destId $version

            if (-not (Test-Path $destVer)) {
                New-Item -ItemType Directory $destVer | Out-Null
            }

            $destLoc = Join-Path $destVer $fileName

            if (-not (Test-Path $destLoc)) {
                Move-Item $destFile $destLoc
            }

            If ($PassThru) {

                $out = [PSCustomObject]@{
                    Name       = $name
                    Version    = $version
                    Uri        = $package
                    Downloaded = $true
                }
                Write-Output $out
            }          
        }       
    } # process
    end {} # end
}  #function Get-MSIXPackages