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
        [System.String]$DestPath = 'D:\App Attach Packages',

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
        [System.String]$VhdxMultiplier = 5
    )

    begin {
        #requires -RunAsAdministrator
        Set-StrictMode -Version Latest
        
        . .\Read-XmlManifest.ps1
    } # begin
    process {
        $fileInfo = Get-ChildItem $Path
        $validExtensions = '.msix','.msixbundle','.appx','.appxbundle'
        If ($validExtensions -notcontains $fileInfo.Extension){
            Write-Error "$($fileInfo.Name) is not a valid file format"
            return
        }

        $manifest = Read-XmlManifest -PathToPackage $Path

        $version = $manifest.Identity.Version

        $name =  $manifest.Identity.Name

        $vhdSize = [math]::Round(($fileInfo.Length * $VhdxMultiplier) / 1MB)
        if ($vhdSize -lt 100){
            $vhdSize = 100
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

            if ($result -like "*Failed*") {
                Remove-Item $directoryPath -Recurse -Confirm:$False
                Write-Error "$($fileInfo.Name) failed to extract to $extension"
                continue
            }
            elseif ($result -like "Successfully created the CIM file*" -or $result -like "Finished unpacking packages to*"){
                $out = [PSCustomObject]@{
                    FullName = $targetPath
                }
                Write-Output $out
                continue
            }

            $result
           
        }

    } # process
    end {} # end
}  #function Convert-MSIXToAppAttach