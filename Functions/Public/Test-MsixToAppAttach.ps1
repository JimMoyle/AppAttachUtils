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
        [System.String]$MsixPackagePath = "C:\MSIXPackages",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$AppAttachPackagePath = "C:\AppAttachPackages",

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
        
    } # begin
    process {

        #Temp
        $MsixPackagePath = Join-Path $MsixPackagePath '19282JackieLiu.Notepads-Beta'

        if ($NoDownload) {
            $files = Get-ChildItem $MsixPackagePath -File -Recurse -Filter "*.msix*"
        }

        $msixPackages = foreach ($msixPackage in $files) {

            $out = [PSCustomObject]@{
                DownloadUrl          = $null
                FileName             = $msixPackage.Name
                ReadManifest         = $null
                Name                 = $null
                PackageFamilyName    = $null
                PackageFullName      = $null
                Version              = $null
                ConvertToCim         = $null
                ConvertToVhdx        = $null
                CimPath              = $null
                VhdxPath             = $null
                W10CimExpansion      = $null
                W10VhdxExpansion     = $null
                W11CimExpansion      = $null
                W11VhdxExpansion     = $null
                W10CimPackageCreate  = $null
                W10VhdxPackageCreate = $null
                W11CimPackageCreate  = $null
                W11VhdxPackageCreate = $null
                W10DesktopAssign     = $null
                W11DesktopAssign     = $null
                Win10AppStart        = $null
                Win11AppStart        = $null
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
                    $diskImagePath = $msixPackage | Convert-MSIXToAppAttach -Type $type -ErrorAction Stop -PassThru -DestPath $AppAttachPackagePath
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

        Sync-PackagesToAzure -LocalPath $AppAttachPackagePath -RemotePath $AzurePackagePath

        $HPlist = [PSCustomObject]@{
            HostPoolType = 'W10'
            HostPoolName = $W10HostPoolName
        }, [PSCustomObject]@{
            HostPoolType = 'W11'
            HostPoolName = $W11HostPoolName
        }
 
        foreach ($diskImage in $msixPackages) {

            foreach ($hp in $HPlist) {
                if ($diskImage.ConvertToVhdx) {
                    $vhdxExpand = $null
                    $azFilesPath = $diskImage.VhdxPath.Replace($AppAttachPackagePath, '\\avdtoolsmsix.file.core.windows.net\appattach\AppAttachPackages')
                    $propClient = $hp.HostPoolType + 'VhdxExpansion'
                    try {
                        $vhdxExpandAll = Expand-MsixDiskImage -HostPoolName $hp.HostPoolName -ResourceGroupName $ResourceGroupName -Path $azFilesPath -ErrorAction Stop
                        $vhdxExpand = $vhdxExpandAll[0]
                        $diskImage.$propClient = $true
                        $diskImage.PackageFamilyName = $vhdxExpand.PackageFamilyName
                        $diskImage.PackageFullName = $vhdxExpand.PackageFullName
                    }
                    catch {
                        $diskImage.$propClient = $false
                    }

                    $createProp = $hp.HostPoolType + 'VhdxPackageCreate'

                    if ($diskImage.$propClient) {
                        $splatNewAzWvdMsixPackage = @{
                            ResourceGroupName     = $ResourceGroupName
                            ErrorAction           = 'Stop'
                            HostPoolName          = $hp.HostPoolName
                            FullName              = $vhdxExpand.PackageFullName
                            LastUpdated           = $vhdxExpand.LastUpdated
                            PackageApplication    = $vhdxExpand.PackageApplication
                            PackageDependency     = $vhdxExpand.PackageDependency
                            PackageFamilyName     = $vhdxExpand.PackageFamilyName
                            PackageRelativePath   = $vhdxExpand.PackageRelativePath
                            Version               = $vhdxExpand.Version
                            PackageName           = $vhdxExpand.PackageName
                            IsActive              = $true
                            IsRegularRegistration = $false
                            ImagePath             = $azFilesPath
                            DisplayName           = 'Vhdx' + $vhdxExpand.PackageName
                        }
                        $createProp = $hp.HostPoolType + 'VhdxPackageCreate'
                        try {
                            New-AzWvdMsixPackage @splatNewAzWvdMsixPackage | Out-Null
                            $diskImage.$createProp = $true
                        }
                        catch {
                            $diskImage.$createProp = $false
                        }
                    }
                    else{
                        $diskImage.$createProp = $false
                    }
                }
                if ($diskImage.ConvertToCim) {
                    $cimExpand = $null
                    $azFilesPath = $diskImage.CimPath.Replace($AppAttachPackagePath, '\\avdtoolsmsix.file.core.windows.net\appattach\AppAttachPackages')
                    $propClient = $hp.HostPoolType + 'CimExpansion'
                    try {
                        $cimExpandAll = Expand-MsixDiskImage -HostPoolName $hp.HostPoolName -ResourceGroupName $ResourceGroupName -Path $azFilesPath -ErrorAction Stop
                        $cimExpand = $cimExpandAll[0]
                        $diskImage.$propClient = $true
                        $diskImage.PackageFamilyName = $cimExpand.PackageFamilyName
                        $diskImage.PackageFullName = $cimExpand.PackageFullName
                    }
                    catch {
                        $diskImage.$propClient = $false
                    }

                    $removeProp = $hp.HostPoolType + 'VhdxPackageCreate'

                    if ($diskImage.$removeProp -and $diskImage.$propClient) {
                        Remove-AzWvdMsixPackage -HostPoolName $hp.HostPoolName -ResourceGroupName  $ResourceGroupName -FullName $cimExpand.PackageFullName
                    }
                    
                    $createProp = $hp.HostPoolType + 'CimPackageCreate'

                    if ($diskImage.$propClient) {
                        $splatNewAzWvdMsixPackage = @{
                            ResourceGroupName     = $ResourceGroupName
                            ErrorAction           = 'Stop'
                            HostPoolName          = $hp.HostPoolName
                            FullName              = $cimExpand.PackageFullName
                            LastUpdated           = $cimExpand.LastUpdated
                            PackageApplication    = $cimExpand.PackageApplication
                            PackageDependency     = $cimExpand.PackageDependency
                            PackageFamilyName     = $cimExpand.PackageFamilyName
                            PackageRelativePath   = $cimExpand.PackageRelativePath
                            Version               = $cimExpand.Version
                            PackageName           = $cimExpand.PackageName
                            IsActive              = $true
                            IsRegularRegistration = $false
                            ImagePath             = $azFilesPath
                            DisplayName           = 'Cim' + $cimExpand.PackageName
                        }
                        
                        try {
                            New-AzWvdMsixPackage @splatNewAzWvdMsixPackage | Out-Null
                            $diskImage.$createProp = $true
                        }
                        catch {
                            $diskImage.$createProp = $false
                        }
                    }
                    else{
                        $diskImage.$createProp = $false
                    }
                }
                
            }
            Write-Output $diskImage
        }
    } # process
    end {} # end
}  #function Test-MsixToAppAttach