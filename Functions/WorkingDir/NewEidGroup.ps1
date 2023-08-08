function New-MsixEidGroup {
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
        #requires -modules Microsoft.Graph
        Set-StrictMode -Version Latest
        . Functions\Private\Read-XmlManifest.ps1
        if (((Get-MgContext).scopes) -notcontains "Group.ReadWrite.All") {
            Write-Error "You must connect to the Microsoft Graph with scope Group.ReadWrite.All before using this function"
            continue
        }
    } # begin
    process {

        $m = read-xmlManifest 'D:\MSIXPackages\Mozilla.MozillaFirefox\113.0.1.0\Firefox%20Setup%20113.0.1.msix'
        $groupName = $m.Properties.DisplayName

        if ((Get-MgGroup -Filter "displayName eq '$GroupName'" | Measure-Object | Select-Object -ExpandProperty Count) -eq 1) {
            Write-Information "Group $GroupName already exists"
            $group = Get-MgGroup -Filter "displayName eq '$GroupName'"
        }
        else {
            $group = New-MgGroup -DisplayName $GroupName -Description $m.Properties.PublisherDisplayName -MailEnabled:$False -SecurityEnabled -MailNickName $m.Identity.Name
        }

        Write-Output $group
        
    } # process
    end {} # end
}  #function New-MsixEidGroup
