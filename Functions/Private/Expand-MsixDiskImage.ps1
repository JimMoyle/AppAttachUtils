function Expand-MsixDiskImage {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ParameterSetName = 'Path',
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Path,

        [Parameter(
            ParameterSetName = 'Url',
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Url,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String[]]$HostPoolName,
        
        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ResourceGroupName
    )

    begin {
        Set-StrictMode -Version Latest
    } # begin
    process {
        foreach ($hp in $HostpoolName) {
            if ($pscmdlet.ParameterSetName -eq 'Url') {
                $uncPath = Convert-MsixPath $Url
            }
            Else {
                $uncPath = $path
            }

            $splatMsixImage = @{
                HostPoolName      = $hp
                ResourceGroupName = $ResourceGroupName
                Uri               = $uncPath
            }

            try {
                $exp = Expand-AzWvdMsixImage @splatMsixImage -Erroraction Stop
                Write-Output $exp
            }
            catch {
                Write-Error "$uncPath Failed Expansion"
            }    
        }
    } # process
    end {} # end
}  #function Expand-MsixDiskImage