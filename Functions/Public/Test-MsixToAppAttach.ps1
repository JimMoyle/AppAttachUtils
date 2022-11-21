function Test-MsixToAppAttach {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Switch]$NoDownload,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$MsixPackagePath = "D:\MSIXPackages",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$AppAttachPackagePath = "D:\AppAttachPackages",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$AzurePackagePath = "Y:\AppAttachPackages",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$W10HostPoolName = 'Win10MsixTest',

        
        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$W11HostPoolName = 'Win11MsixTest',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$ResourceGroupName = 'AVDPermanent'

        
    )

    begin {
        Set-StrictMode -Version Latest

        $Private = @( Get-ChildItem -Path D:\GitHub\AppAttachUtils\Functions\Private\*.ps1 -ErrorAction SilentlyContinue )

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
        
    } # begin
    process {

        #Temp
        $MsixPackagePath = Join-Path $MsixPackagePath '33823Nicke.ScreenToGif'

        if ($NoDownload) {
            $files = Get-ChildItem $MsixPackagePath -File -Recurse -Filter "*.msix*"
        }

        $msixPackages = foreach ($msixPackage in $files) {

            $out = [PSCustomObject]@{
                FileName         = $msixPackage.Name
                ReadManifest     = $null
                Name             = $null
                Version          = $null
                ConvertToCim     = $null
                ConvertToVhdx    = $null
                CimPath          = $null
                VhdxPath         = $null
                W10CimExpansion  = $null
                W10VhdxExpansion = $null
                W11CimExpansion  = $null
                W11VhdxExpansion = $null
                PackageAlias     = $null
            }

            try {
                $manifestInfo = $msixPackage | Read-XmlManifest -ErrorAction Stop
                $out.ReadManifest = $true
                $out.Name = $manifestInfo.Identity.Name
                $out.Version = $manifestInfo.Identity.Version
            }
            catch {
                $out.ReadManifest = $false
                Write-Output $out
                continue
            }

            foreach ($type in @('Cim', 'Vhdx')) {

                $property = 'ConvertTo' + $type
                $imagePathProp = $type + 'Path'

                try {
                    $diskImagePath = $msixPackage | Convert-MSIXToAppAttach -Type $type -ErrorAction Stop -PassThru
                    $out.$imagePathProp = $diskImagePath.FullName
                    $out.$property = $true
                }
                catch {
                    $out.$property = $false
                    Write-Output $out
                    continue
                }
   
            }
            Write-Output $out
        }

        Sync-PackagesToAzure

        $HPlist = [PSCustomObject]@{
            HostPoolType = 'W10'
            HostPoolName = $W10HostPoolName
        }, [PSCustomObject]@{
            HostPoolType = 'W11'
            HostPoolName = $W11HostPoolName
        }

    
        
        foreach ($diskImage in $msixPackages) {

            foreach ($hp in $HPlist) {
                if ($diskImage.ConvertToCim) {

                    $azFilesPath = $diskImage.CimPath.Replace('D:\AppAttachPackages', '\\avdtoolsmsix.file.core.windows.net\appattach\AppAttachPackages')
                    $propClient = $hp.HostPoolType + 'CimExpansion'
                    try {
                        $cimExpand = Expand-MsixDiskImage -HostPoolName $hp.HostPoolName -ResourceGroupName $ResourceGroupName -Path $azFilesPath -ErrorAction Stop
                        $diskImage.PackageAlias = $cimExpand.PackageAlias
                        
                        $diskImage.$propClient = $true
                    }
                    catch {
                        $diskImage.$propClient = $false
                    }
                }
                if ($diskImage.ConvertToVhdx) {

                    $azFilesPath = $diskImage.VhdxPath.Replace('D:\AppAttachPackages', '\\avdtoolsmsix.file.core.windows.net\appattach\AppAttachPackages')
                    $propClient = $hp.HostPoolType + 'VhdxExpansion'
                    try {
                        $VhdxExpand = Expand-MsixDiskImage -HostPoolName $hp.HostPoolName -ResourceGroupName $ResourceGroupName -Path $azFilesPath -ErrorAction Stop
                        $diskImage.PackageAlias = $VhdxExpand.PackageAlias
                        $diskImage.$propClient = $true
                    }
                    catch {
                        $diskImage.$propClient = $false
                    }
                }
            }
            Write-Output $diskImage
        }

    } # process
    end {} # end
}  #function Test-MsixToAppAttach