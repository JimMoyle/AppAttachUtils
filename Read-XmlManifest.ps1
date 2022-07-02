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
            $FileToRead = 'AppxBundleManifest.xml'
        }
        Else {
            $FileToRead = 'AppxManifest.xml'
        }

        Add-Type -assembly "system.io.compression.filesystem"
        $zip = [io.compression.zipfile]::OpenRead($PathToPackage)
        $file = $zip.Entries | where-object { $_.Name -eq $FileToRead}

        $stream = $file.Open()
        $reader = New-Object IO.StreamReader($stream)
        $text = $reader.ReadToEnd()

        $reader.Close()
        $stream.Close()
        $zip.Dispose()

        [xml]$xml = $text

        If ($FileToRead -eq 'AppxBundleManifest.xml'){
            Write-Output $xml.Bundle
        }
        Else {
            Write-Output $xml.Package
        }

        
        
    } # process
    end {} # end
}  #function Read-XmlManifest