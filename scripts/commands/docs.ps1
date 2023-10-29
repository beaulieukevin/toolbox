$appConfig = Get-AppConfig
$docsUrl = $appConfig.toolbox.docsUrl
    
if ($docsUrl) {
    Write-Host "Opening $docsUrl in your default browser."
    Start-Process "$docsUrl"
    return
}

Write-Host "There is no documentation available."
