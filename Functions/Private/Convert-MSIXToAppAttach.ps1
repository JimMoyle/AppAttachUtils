function Convert-MSIXToAppAttach {
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
        [System.String]$DestPath = 'D:\AppAttachPackages',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [ValidateSet('vhdx', 'cim')]
        [System.String[]]$Type = 'cim',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$PassThru,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [double]$VhdxMultiplier = 1.2,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [string]$TempExpandPath = 'D:\TempExpand',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [int]$VhdxMultiplierLimit = 21
    )

    begin {
        #requires -RunAsAdministrator
        Set-StrictMode -Version Latest
        
        #. .\Read-XmlManifest.ps1
    } # begin
    process {
        $fileInfo = Get-ChildItem $Path
        $validExtensions = '.msix', '.msixbundle', '.appx', '.appxbundle'
        If ($validExtensions -notcontains $fileInfo.Extension) {
            Write-Error "$($fileInfo.Name) is not a valid file format"
            return
        }

        $manifest = Read-XmlManifest -PathToPackage $Path

        $version = $manifest.Identity.Version

        $name = $manifest.Identity.Name

        if (Test-Path $TempExpandPath ) {
            Remove-Item $TempExpandPath -Force -Recurse -Confirm:$False
        }

        New-Item $TempExpandPath -ItemType Directory  | Out-Null

        Expand-Archive -Path $Path -DestinationPath $TempExpandPath 

        $vhdSize = ((Get-ChildItem $TempExpandPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB) * $VhdxMultiplier

        $vhdSize = [Math]::Ceiling($vhdSize)

        if ($vhdSize -lt 10) {
            $vhdSize = 10
        }

        
        foreach ($extension in $Type) {

            $directoryPath = Join-Path $DestPath (Join-Path $name (Join-Path $version $extension ))
            $targetPath = (Join-Path $directoryPath $fileInfo.Name).Replace($fileInfo.Extension, ('.' + $extension))

            if (Test-Path $targetPath) {
                continue
            }
            if (-not(Test-Path $directoryPath)) {
                New-Item -ItemType Directory $directoryPath | Out-Null
            }
            $result = & 'C:\Program Files\MSIXMGR\msixmgr.exe' -Unpack -packagePath $Path -destination $targetPath -applyacls -create -filetype $extension -rootDirectory apps -vhdSize $vhdSize


            switch ($true) {
                { $result -like "Successfully created the CIM file*" } { $completed = $true; break }
                { $result -like "Finished unpacking packages to*" } { $completed = $true; break }
                { $VhdxMultiplier -gt $VhdxMultiplierLimit } { 
                    Write-Error "$($fileInfo.Name) failed to extract to $extension with $VhdxMultiplierLimit x expanded package space"
                    $completed = $False
                    break
                }
                { $result -like "*Failed with HRESULT 0x8bad0003*" } {

                    $splatConvertMSIXToAppAttach = @{
                        Path           = $Path
                        DestPath       = $DestPath
                        Type           = 'vhdx'
                        PassThru       = $true
                        VhdxMultiplier = $VhdxMultiplier * 1.5
                        TempExpandPath = $TempExpandPath
                    }
                    Convert-MSIXToAppAttach @splatConvertMSIXToAppAttach
                    $completed = $false
                    break
                }
                { $result -like "*Failed*" } {

                    $result -match "Failed with HRESULT (\S+) when trying to unpack"
                    $errorCode = $Matches[1]
                    Write-Error "$($fileInfo.Name) failed to extract to $extension with error code $errorCode"
                    break
                }
                Default {}
            }

            if ($completed) {
                $out = [PSCustomObject]@{
                    FullName = $targetPath
                }
                Write-Output $out
            }        
        }

        Remove-Item $TempExpandPath -Force -Recurse -Confirm:$False

    } # process
    end {} # end
}  #function Convert-MSIXToAppAttach