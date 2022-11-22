function Sync-PackagesToAzure {
    [CmdletBinding()]

    Param (
        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$LocalPath = "D:\AppAttachPackages\",

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$RemotePath = 'Y:\AppAttachPackages\',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$NoMirror
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        if ($NoMirror) {
            robocopy $LocalPath $RemotePath
        }
        else {
            robocopy $LocalPath $RemotePath /mir
        }
        
        
    } # process
    end {} # end
}  #function Sync-PackagesToAzure