function Test-AppAttachManifest {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Alias('FullName')]
        [System.String]$Path
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {

        $fileInfo = Get-ChildItem -Path $Path -File

        If ($fileInfo.Extension -eq '.vhdx') {

            $mount = Mount-FslDisk -Path $Path -ReadOnly -PassThru

            if (Get-ChildItem -Path $mount.Path -Filter "Appx*manifest.xml" -Recurse -ErrorAction SilentlyContinue -Force) {
                $true
            }
            else {
                $false
            }

            $mount | Dismount-FslDisk
        }

        If ($fileInfo.Extension -eq '.cim') {

            $mount = Mount-CimDiskImage -ImagePath $Path -PassThru -DriveLetter W:

            if (Get-ChildItem -Path $mount.Path -Filter "Appx*manifest.xml" -Recurse -ErrorAction SilentlyContinue -Force) {
                $true
            }
            else {
                $false
            }

            $mount | Dismount-CimDiskImage
        }
    } # process
    end {} # end
}  #function Test-AppAttach