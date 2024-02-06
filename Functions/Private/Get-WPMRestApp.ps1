function Get-WPMRestApp {
    [CmdletBinding()]

    Param (

        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Alias('Id')]
        [System.String]$PackageIdentifier,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$PackageName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$Publisher,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$Uri = 'https://pkgmgr-wgrest-pme.azurefd.net/api/packageManifests/'
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        $queryUri = $Uri.TrimEnd('/') + '/' + $PackageIdentifier

        try{
            $package = Invoke-RestMethod -Uri $queryUri
        }
        catch{
            Write-Error "Cannot query Package $PackageIdentifier"
        }

        $packageDetail = $package.Data.Versions | 
            Select-Object @{Name = 'PackageVersion'; Expression = { [Version]$_.PackageVersion } }, Installers | 
            Sort-Object -Property PackageVersion -Descending | 
            Select-Object -First 1

        foreach ($installer in $packageDetail.Installers) {
            if ($installer.InstallerType -eq 'msix' ) {

                $installer | Add-Member -NotePropertyName PackageVersion -NotePropertyValue $packageDetail.PackageVersion
                $installer | Add-Member -NotePropertyName PackageIdentifier -NotePropertyValue $PackageIdentifier
                if ($Publisher) {
                    $installer | Add-Member -NotePropertyName Publisher -NotePropertyValue $Publisher
                }
                else{
                    $installer | Add-Member -NotePropertyName Publisher -NotePropertyValue $null
                }
                
                if ($PackageName) {
                    $installer | Add-Member -NotePropertyName PackageName -NotePropertyValue $PackageName
                }
                else{
                    $installer | Add-Member -NotePropertyName PackageName -NotePropertyValue $null
                }
                
                Write-Output $installer
            }
            
        }

    } # process
    end {} # end
}  #function Get-WPMRestApp