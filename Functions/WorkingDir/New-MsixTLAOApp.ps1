function New-MsixAppVersion {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Name,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$ResourceGroupName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$Location,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [ValidateSet('Unhealthy', 'NeedsAssistance', 'DoNotFail')]
        [System.String]$FailHealthCheckOnStagingFailure = 'NeedsAssistance',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [Switch]$IsLogonBlocking = $false,

        [Parameter(
            ValuefromPipelineByPropertyName = $true,
            Mandatory = $true
        )]
        [System.String]$DisplayName,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String[]]$HostpoolReference,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$PermissionsToAdd,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$PermissionsToRemove
    )
    begin {
        #requires -Modules Microsoft.Graph, Az.Accounts, @{ModuleName="Az.DesktopVirtualization";ModuleVersion="3.4.3"}
        Set-StrictMode -Version Latest
    } # begin
    process {

        if ((Get-AzWvdAppAttachPackage | Where-Object { $_.Name -eq $Name } | Measure-Object).Count -ne 0){
            $package = Update-AzWvdAppAttachPackage @PSBoundParameters
        }
        else{
            $package = New-AzWvdAppAttachPackage @PSBoundParameters
        }
       Write-Output $package
    } # process
    end {} # end
}  #function New-MsixApp