<#
.SYNOPSIS
    Reads the manifest file of an application package or disk image.

.DESCRIPTION
    This function reads the manifest file of an application package or disk image. The manifest file contains information about the package, such as its identity, properties, resources, dependencies, capabilities, and applications.

.PARAMETER Path
    Specifies the path to the application package or disk image. This parameter is mandatory.

.INPUTS
    System.IO.FileInfo

.OUTPUTS
    System.Management.Automation.PSCustomObject

.EXAMPLE
    Read-XmlManifest -Path "C:\MyAppPackage.appx"

    This example reads the manifest file of the "MyAppPackage.appx" application package.

.EXAMPLE
    Read-XmlManifest -Path "D:\MyDiskImage.vhdx"

    This example reads the manifest file of the "MyDiskImage.vhdx" disk image.

.NOTES
    Author: Unknown
    Last Edit: Unknown
#>

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
        # This function is used to get the path of the manifest file of an application package or disk image.
        function Get-ManifestPath {
            param ($Path)
            # Set the names of the manifest files for an application package and bundle respectively.
            $bundleFile = 'AppxBundleManifest.xml'
            $file = 'AppxManifest.xml'
            # Get the manifest file(s) in the specified path.
            $fileInfo = Get-ChildItem -Path $Path -Filter $bundleFile -Recurse
            # If there is one manifest bundle file found, output it.
            if (($fileInfo | Measure-Object).Count -eq 1) {
                Write-Output $fileInfo
            }
            # If there are no manifest bundle files found, output the one for an application package.
            else {
                $fileInfo = Get-ChildItem -Path $Path -Filter $file -Recurse
                Write-Output $fileInfo
            }
        }
    } # begin
    process {

        $fileInfo = Get-ChildItem -Path $Path

        if ($fileInfo.Extension -like ".vhd?") {

            $mount = Mount-FslDisk -Path $Path -ReadOnly -PassThru

            $fileInfo = Get-ManifestPath -Path $mount.Path
            [xml]$xml = Get-Content $fileInfo.FullName

            $mount | Dismount-FslDisk
        }

        if ($fileInfo.Extension -eq '.cim') {

            $tmpFolder = $Env:TEMP
            $RandomName = (New-Guid).guid
            $tempDirPath = New-Item -ItemType Directory -Path (Join-Path $tmpFolder $randomName) 

            $mount = Mount-CimDiskImage -ImagePath $Path -MountPath $TempDirPath -PassThru

            $fileInfo = Get-ManifestPath -Path $mount.Path
            [xml]$xml = Get-Content $fileInfo.FullName

            $mount | Dismount-CimDiskImage

            $tempDirPath | Remove-Item
        }

        if ($fileInfo.Extension -like "*appx*" -or $fileInfo.Extension -like "*msix*") {

            if ($fileInfo.Extension -like ".*bundle") {
                $fileToRead = 'AppxMetadata/AppxBundleManifest.xml'
            }
            else{
                $fileToRead = 'AppxManifest.xml'
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

        if ($xml.psobject.Properties.Name -contains 'Bundle') {
            $output = $xml.Bundle | Select-Object Identity
        }
        else {
            $output = $xml.Package | Select-Object Identity
        }
        Write-Output $output
    } # process
    end {} # end
}  #function Read-XmlManifest