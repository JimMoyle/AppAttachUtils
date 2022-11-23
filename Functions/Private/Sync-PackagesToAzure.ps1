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
        [Switch]$NoMirror,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$PassThru
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        if ($NoMirror) {
            $roboresult = robocopy $LocalPath $RemotePath /s /xx
        }
        else {
            $roboresult = robocopy $LocalPath $RemotePath /mir
        }

        if ($PassThru) {
            Write-Output $roboresult
        }
        
        
    } # process
    end {} # end
}  #function Sync-PackagesToAzure