function Read-XmlManifest {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [ValidateScript({
                if (-Not ($_ | Test-Path) ) { throw "File or folder does not exist" }
                if (-Not ($_ | Test-Path -PathType Leaf) ) { throw "The Path argument must be a file. Folder paths are not allowed." }
                if ($_ -notmatch "\.msix$|\.vhdx?$|\.appx$|\.cim$|(?:\.msi|\.app)xbundle$") {
                    throw "The file specified must be either of type disk image or application package"
                }
                return $true
            })]
        [Alias('FullName')]
        [System.IO.FileInfo]$Path
    )

    begin {
        Set-StrictMode -Version Latest
        #requires -RunAsAdministrator
        #requires -Modules CimDiskImage
    } # begin
    process {

        $fileInfo = Get-ChildItem -Path $Path
        $fileToRead = 'AppxManifest.xml'

        if ($fileInfo.Extension -like ".vhd?") {

            $mount = Mount-FslDisk -Path $Path -ReadOnly -PassThru

            $fileInfo = Get-ChildItem -Path $mount.Path -Filter $fileToRead -Recurse
            [xml]$xml = Get-Content $fileInfo.FullName

            $mount | Dismount-FslDisk
            
        }

        if ($fileInfo.Extension -eq '.cim') {
            if ($null -eq (Get-Module cimdiskimage -ListAvailable)) {
                Write-Error "Reading the manifest file from a cim disk image requires the use of the cimdiskimage module, use Install-Module CimDiskImage"
                continue
            }

            $tmpFolder = $Env:TEMP
            $RandomName = (New-Guid).guid
            $tempDirPath = New-Item -ItemType Directory -Path (Join-Path $tmpFolder $randomName) 

            $mount = Mount-CimDiskImage -ImagePath $Path -MountPath $TempDirPath -PassThru

            $fileInfo = Get-ChildItem -Path $mount.Path -Filter $fileToRead -Recurse
            [xml]$xml = Get-Content $fileInfo.FullName

            $mount | Dismount-CimDiskImage

            $tempDirPath | Remove-Item
            
        }

        if ($fileInfo.Extension -like "*appx*" -or $fileInfo.Extension -like "*msix*") {

            if ($fileInfo.Extension -eq ".msixbundle") {
                $fileToRead = 'AppxBundleManifest.xml'
            }

            if ($fileInfo.Extension -eq ".appxbundle") {
                $fileToRead = 'AppxMetadata/AppxBundleManifest.xml'
            }

            Add-Type -assembly "system.io.compression.filesystem"
            $zip = [io.compression.zipfile]::OpenRead($Path)
            $file = $zip.Entries | where-object { $_.FullName -eq $fileToRead }
    
            $stream = $file.Open()
            $reader = New-Object IO.StreamReader($stream)
            [xml]$xml = $reader.ReadToEnd()
    
            $reader.Close()
            $stream.Close()
            $zip.Dispose()

        }

        if ($fileToRead -like "*AppxBundleManifest.xml") {
            Write-Output $xml.Bundle
        }
        else {
            $output = $xml.Package | Select-Object Identity, Properties, Resources, Dependencies, Capabilities, Applications
            Write-Output $output
        }
    } # process
    end {} # end
}  #function Read-XmlManifest