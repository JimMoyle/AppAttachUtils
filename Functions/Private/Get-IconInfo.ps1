function Get-IconInfo {
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
        Set-StrictMode -Version Latest
    } # begin
    process {
        if (Test-Path $Path){
            $fileInfo = Get-ChildItem $Path
        }
        else{
            Write-Error "$Path not found"
        }

        if ($fileInfo.Extension -ne '.png') {
            Write-Error "Only support png"
            return
        }

        Add-Type -AssemblyName System.Drawing
        $png = New-Object System.Drawing.Bitmap $Path

        if ($png.Height -ne $png.Width){
            return
        }

        $out = [PSCustomObject]@{
            FullName = $Path
            Height = $png.Height
            Width = $png.Width
            Area = $png.Width * $png.Height
            HorizontalResolution = $png.HorizontalResolution
            VerticalResolution = $png.VerticalResolution
            PixelFormat = $png.PixelFormat
        }

        Write-Output $out

    } # process
    end {} # end
}  #function Get-IconInfo