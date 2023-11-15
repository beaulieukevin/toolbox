$toolboxVersion = Get-ToolboxVersion
$configVersion = Get-CompanyConfigVersion
$orgName = Get-CompanyName

Write-Host "Toolbox $toolboxVersion"
Write-Host "$orgName configuration $configVersion"