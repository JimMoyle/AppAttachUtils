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
        [psobject]$Manifest
    )

    begin {
        #requires -modules Microsoft.Graph
        Set-StrictMode -Version Latest
        $graphContext = Get-MgContext
        $errResult = $false

        if (($graphContext | Measure-Object).Count -eq 0) {
            Write-Error "You must connect to the Microsoft Graph with scope Group.ReadWrite.All and RoleManagement.ReadWrite.Directory before using this function"
            $errResult = $true
        }

        if ((($graphContext).scopes) -notcontains "Group.ReadWrite.All") {
            Write-Error "You must connect to the Microsoft Graph with scope Group.ReadWrite.All before using this function"
            $errResult = $true
        }

        if ((($graphContext).scopes) -notcontains "RoleManagement.ReadWrite.Directory") {
            Write-Error "You must connect to the Microsoft Graph with scope Group.ReadWrite.All before using this function"
            $errResult = $true
        }

        if ($errResult) {
            return
        }

    } # begin
    process {
        $name = $Manifest.Identity.Name

        if ((Get-MgGroup -Filter "displayName eq '$name'" | Measure-Object | Select-Object -ExpandProperty Count) -ge 1) {
            Write-Information "Group $name already exists"
            $group = Get-MgGroup -Filter "displayName eq '$name'"
        }
        else {
            try {

                if ($name -like "*.*") {
                    $mailNickName = $name.Split('.')[1]
                }
                else {
                    $mailNickName = $name
                }

                $params = @{
                    DisplayName        = $name
                    Description        = (($Manifest.Identity.Attributes).'#text' -join ' ')
                    MailEnabled        = $false
                    SecurityEnabled    = $true
                    MailNickName       = $mailNickName
                    IsAssignableToRole = $true
                    ErrorAction        = 'Stop'
                }
    
                $group = New-MgGroup @params
            }
            catch {
                Write-Error $error[0]
            }

        }

        Write-Output $group
        
    } # process
    end {} # end
}  #function New-MsixEidGroup