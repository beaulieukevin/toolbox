$docsUrl = Get-CompanyDocsUrl
    
if (!$docsUrl) {
    Write-Host "There is no documentation available."
    return
}

Write-Host "Opening $docsUrl in your default browser."
Start-Process $docsUrl