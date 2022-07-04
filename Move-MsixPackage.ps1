function Move-MSIXPackage {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Alias('FullName')]
        [System.String]$Path,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$DestPath = 'D:\MSIX Packages'
    )

    begin {
        Set-StrictMode -Version Latest

        . .\Read-XmlManifest.ps1
    } # begin
    process {

        If (-not (Test-Path $Path)){
            Write-Error "$Path not found"
            return
        }

        $fileInfo = Get-ChildItem $Path

        $manifest = Read-XmlManifest -PathToPackage $Path

        $version = $manifest.Identity.Version

        $name =  $manifest.Identity.Name

        $destinationFolder = Join-Path $DestPath (Join-Path $name $version)

        If (-not (Test-Path $destinationFolder)){
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
        }

        $destination = Join-Path $destinationFolder $fileInfo.Name

        If (-not (Test-Path $destination)){
            Move-Item -Path $Path -Destination $destination -Force
        }
        
    } # process
    end {} # end
}  #function Move-MSIXPackage