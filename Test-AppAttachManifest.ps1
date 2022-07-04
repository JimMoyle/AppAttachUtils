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
    } # process
    end {} # end
}  #function Test-AppAttach