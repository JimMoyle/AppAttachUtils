function Read-XmlManifest {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Alias('FullName')]
        [System.String]$PathToPackage
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {

        $fileInfo = Get-ChildItem -Path $PathToPackage

        If ($fileInfo.Extension -like "*bundle*"){
            $fileToRead = 'AppxBundleManifest.xml'
        }
        Else {
            $fileToRead = 'AppxManifest.xml'
        }

        Add-Type -assembly "system.io.compression.filesystem"
        $zip = [io.compression.zipfile]::OpenRead($PathToPackage)
        $file = $zip.Entries | where-object { $_.Name -eq $fileToRead}

        $stream = $file.Open()
        $reader = New-Object IO.StreamReader($stream)
        [xml]$xml = $reader.ReadToEnd()

        $reader.Close()
        $stream.Close()
        $zip.Dispose()

        If ($fileToRead -eq 'AppxBundleManifest.xml'){
            Write-Output $xml.Bundle
        }
        Else {
            Write-Output $xml.Package
        }
       
    } # process
    end {} # end
}  #function Read-XmlManifest