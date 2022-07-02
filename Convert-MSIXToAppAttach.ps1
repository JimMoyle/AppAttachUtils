function Convert-MSIXToAppAttach {
    [CmdletBinding()]

    Param (
        [Parameter(
            Position = 0,
            ValuefromPipelineByPropertyName = $true,
            ValuefromPipeline = $true,
            Mandatory = $true
        )]
        [System.String]$Path,

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [System.String]$DestPath = 'D:\App Attach Packages',

        [Parameter(
            ValuefromPipelineByPropertyName = $true
        )]
        [ValidateSet('vhdx', 'cim')]
        [System.String[]]$Type = 'cim'
    )

    begin {
        #requires -RunAsAdministrator
        Set-StrictMode -Version Latest
    } # begin
    process {
        $pathSplit = $Path.Split('\')
        $pathRoot = Join-Path $pathSplit[0] $pathSplit[1]
        $targetRoot = $Path.Replace("$pathRoot", "$DestPath")
        $fileInfo = Get-ChildItem $Path

        $vhdSize = [math]::Round(($fileInfo.Length * 10) / 1MB)
        if ($vhdSize -lt 100){
            $vhdSize = 100
        }

        foreach ($extension in $Type) {
            $targetPath = $targetRoot.Replace($fileInfo.Extension, ('.' + $extension))
            $directoryPath = Join-Path $DestPath (Join-Path $pathSplit[2] $pathSplit[3])
            if (Test-Path $targetPath) {
                return
            }
            if (-not(Test-Path $directoryPath)) {
                New-Item -ItemType Directory $directoryPath | Out-Null
            }
            $result = & 'C:\Program Files\MSIXMGR\msixmgr.exe' -Unpack -packagePath $Path -destination $targetPath -applyacls -create -filetype $extension -rootDirectory apps -vhdSize $vhdSize

            $result
        }

    } # process
    end {} # end
}  #function Convert-MSIXToAppAttach