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
        [System.String]$RemotePath = 'Z:\AppAttachPackages\',

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

        if (-not (Test-Path $RemotePath)) {
            Write-Error "$RemotePath not found"
            continue
        }

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