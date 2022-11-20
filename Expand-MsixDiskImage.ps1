#Expand-MsixDiskImage

$ResourceGroupName = 'AVDPermanent'
$HPName = 'MSIXExtraction'

$splatMsixImage = @{
    HostPoolName = $HPName
    ResourceGroupName = $ResourceGroupName
}

$uri = 'https://avdtoolsmsix.file.core.windows.net/appattach/Mozilla.MozillaFirefox/104.0.0.0/vhdx/Firefox Setup 104.0.vhdx'

$unc = Convert-MsixPath $uri

$exp = Expand-AzWvdMsixImage @splatMsixImage -Uri $unc

New-AzWvdMsixPackage @splatMsixImage -PackageAlias mozillamozillafirefox -ImagePath $unc -HostPoolName PooledWin10