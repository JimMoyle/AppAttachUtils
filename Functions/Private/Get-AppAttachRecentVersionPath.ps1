function Get-AppAttachRecentVersionPath {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Path,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$GetVhdx
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        
        $versionFolders = Get-ChildItem -Path $Path -Directory

        $versions = foreach ($ver in $versionFolders.Name) {
            [version]$ver
        }

        $mostRecent = $versions | Sort-Object -Descending | Select-Object -First 1

        $diskPath = Join-Path $Path $mostRecent.ToString()

        $splatGetChildItem = @{
            Path    = $diskPath
            Recurse = $true
            File    = $true
        }
        if ($GetVhdx) {
            $outPath = Get-ChildItem @splatGetChildItem -Filter *.vhdx
        }
        else {
            $outPath = Get-ChildItem @splatGetChildItem -Filter *.cim
        }

        Write-Output $outPath

    } # process
    end {} # end
}  #function Get-AppAttachRecentVersion
