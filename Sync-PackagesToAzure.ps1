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
        [System.String]$RemotePath = "https://avdtoolsmsix.file.core.windows.net/appattach",

        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Token
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {

        $param = $RemotePath + $Token

        #azcopy sync 'C:\myDirectory' 'https://mystorageaccount.file.core.windows.net/myfileShare?sv=2018-03-28&ss=bfqt&srt=sco&sp=rwdlacup&se=2019-07-04T05:30:08Z&st=2019-07-03T21:30:08Z&spr=https&sig=CAfhgnc9gdGktvB=ska7bAiqIddM845yiyFwdMH481QA8%3D' --recursive
        & azcopy sync $LocalPath $param --recursive
    } # process
    end {} # end
}  #function Sync-PackagesToAzure