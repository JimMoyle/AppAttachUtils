function New-EidGraphGroup {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [Alias('GroupName')]
        [System.String]$Name
    )

    begin {
        #requires -modules Microsoft.Graph
        Set-StrictMode -Version Latest
        . Functions\Private\Read-XmlManifest.ps1
        if (((Get-MgContext).scopes) -notcontains "Group.ReadWrite.All") {
            Write-Error "You must connect to the Microsoft Graph with scope Group.ReadWrite.All before using this function"
            continue
        }
    } # begin
    process {

        if ((Get-MgGroup -Filter "displayName eq '$Name'" | Measure-Object | Select-Object -ExpandProperty Count) -eq 1) {
            Write-Information "Group $Name already exists"
            $group = Get-MgGroup -Filter "displayName eq '$Name'"
        }
        else {
            $group = New-MgGroup -DisplayName $Name -Description (($m.bundle.Identity.Attributes).'#text' -join ' ') -MailEnabled:$False -SecurityEnabled -MailNickName $m.Identity.Name
        }

        Write-Output $group
        
    } # process
    end {} # end
}  #function New-MsixEidGroup