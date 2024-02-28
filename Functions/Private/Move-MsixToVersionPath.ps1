function Move-MsixToVersionPath {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Alias('PSPath')]
        [System.String]$Path,

        [Parameter(
            Position = 1,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [String]$DestPath,
        
        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$PassThru
    )

    begin {
        Set-StrictMode -Version Latest
        . Functions\Private\Read-XmlManifest.ps1
    } # begin
    process {

        if (-not (Test-Path $Path)) {
            Write-Error "The path $Path does not exist"
            continue
        }

        $fileInfo = Get-ChildItem -Path $Path

        if ($fileInfo.Extension -notlike "*.msix*" -and $fileInfo.Extension -notlike "*.appx*" ) {
            continue
        }

        $manifest = Read-XmlManifest $Path

        $version = $manifest.Identity.Version

        $name = $manifest.Identity.Name

        $destId = Join-Path $DestPath $name
        $destVer = Join-Path $destId $version

        if (-not (Test-Path $destVer)) {
            New-Item -ItemType Directory $destVer | Out-Null
        }

        $destLoc = Join-Path $destVer $fileInfo.PSChildName

        if (-not (Test-Path $destLoc)) {
            Move-Item $Path $destLoc
        }

        If ($PassThru) {

            $out = [PSCustomObject]@{
                Name    = $name
                Version = $version
                Path = $destLoc
            }
            Write-Output $out
        }          
    } # process
    end {} # end
}  #function Move-MsixToVersionPath