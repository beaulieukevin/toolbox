$toolboxVersion = Get-ToolboxVersion
    
if ($toolboxVersion) {
    Write-Host "Toolbox $toolboxVersion"
    return
}

Write-Host "Toolbox [UNKNOWN_VERSION]"
