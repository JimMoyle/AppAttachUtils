$W11groupassignment = Get-AzWvdApplication -GroupName Win11MSIXTest-DAG -ResourceGroupName AVDPermanent

foreach ($assign in $W11groupassignment){
    Remove-AzWvdApplication -GroupName Win11MSIXTest-DAG -ResourceGroupName AVDPermanent -Name $assign.Name.Split('/')[1]
}

$W11groupassignment = Get-AzWvdApplication -GroupName Win10MSIXTest-DAG -ResourceGroupName AVDPermanent

foreach ($assign in $W10groupassignment){
    Remove-AzWvdApplication -GroupName Win11MSIXTest-DAG -ResourceGroupName AVDPermanent -Name $assign.Name.Split('/')[1]
}

$W11Apps = Get-AzWvdMsixPackage -HostPoolName Win11MsixTest -ResourceGroupName AVDPermanent
foreach ($app in $W11Apps) {
    $fullName = $app.Name.Split('/')[1]
    Remove-AzWvdMsixPackage -HostPoolName Win11MsixTest -ResourceGroupName AVDPermanent -FullName $fullName
}

$W10Apps = Get-AzWvdMsixPackage -HostPoolName Win10MsixTest -ResourceGroupName AVDPermanent
foreach ($app in $W10Apps) {
    $fullName = $app.Name.Split('/')[1]
    Remove-AzWvdMsixPackage -HostPoolName Win10MsixTest -ResourceGroupName AVDPermanent -FullName $fullName
}

