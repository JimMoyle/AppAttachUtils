function Sync-PackagesToAzure {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [System.String]$LocalPath = "D:\AppAttachPackages\",

        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [System.String]$RemotePath = 'Y:\AppAttachPackages\'
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {

        robocopy  $LocalPath $RemotePath /mir
        
    } # process
    end {} # end
}  #function Sync-PackagesToAzure