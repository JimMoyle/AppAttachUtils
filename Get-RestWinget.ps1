winget source add --name REST --arg https://pkgmgr-wgrest-pme.azurefd.net/api --type Microsoft.Rest

$s = winget search "visual" -s REST

winget show 1ic.BPMN-RPAstudio -s REST

$r = winget show 1ic.BPMN-RPAstudio -s REST