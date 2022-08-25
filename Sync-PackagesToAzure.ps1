function Sync-PackagesToAzure {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [System.String]$LocalPath = "D:\AppAttachPackages",

        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true
        )]
        [System.String]$RemotePath = 'Z:'
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {


        
    } # process
    end {} # end
}  #function Sync-PackagesToAzure