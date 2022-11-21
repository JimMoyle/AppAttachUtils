function Convert-MsixPath {
    param (
       $url
    )

    $url = $url -replace 'https://','\\'
    $url = $url -replace '/','\'

    $url
    Set-Clipboard -Value $url
   
}