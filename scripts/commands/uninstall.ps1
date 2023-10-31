param(
    [Parameter(Position = 0)]
    [array]$Arguments
)

function Remove-Tool($PlanName) {
    if (!$PlanName) {
        return
    }

    $folderName = Get-PlanPackageFolder -PlanName $PlanName

    if (!$folderName) {
        return
    }
    
    Write-Host "Removing '$PlanName' tool from Toolbox..."
    Remove-Directory -Path "$Env:TOOLBOX_APPS\$folderName"
    Write-Host "Successfully removed '$PlanName' tool from Toolbox."
}

function Remove-Link($PlanName) {
    if (!$PlanName) {
        return
    }
    
    $shortcutName = Get-PlanPackageShortcutName -PlanName $PlanName

    if (!$shortcutName) {
        return
    }
    
    Write-Host "Removing '$PlanName' shortcut from your desktop..."
    Remove-Shortcut -ShortcutName $shortcutName
    Write-Host "Successfully removed '$PlanName' shortcut from your desktop."
}

function Remove-Cli($PlanName) {
    if (!$PlanName) {
        return
    }

    $cliName = Get-PlanCli -PlanName $PlanName

    if (!$cliName) {
        return
    }
    
    Write-Host "Removing '$cliName' CLI from Toolbox..."
    Remove-Item -Path "$Env:TOOLBOX_BIN\$cliName.bat" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Successfully removed '$cliName' CLI from Toolbox."
}

function Remove-Plan($PlanName) {
    if (!$PlanName) {
        return
    }

    Write-Host "Removing '$PlanName' plan from Toolbox..."
    Remove-Directory -Path "$Env:TOOLBOX_PLANS\$PlanName"
    Write-Host "Successfully removed '$PlanName' plan from Toolbox."
}

if (!$Arguments) {
    Write-Host "You must provide a plan name to uninstall it.`n"
    Write-Help
    return
}

$planName = Get-FirtArgument $Arguments
    
if (!(Test-PlanConfig -PlanName $planName)) {
    Write-Host "The plan '$planName' is not downloaded via Toolbox."
    return
}

Write-Task "Uninstalling '$planName' from Toolbox"

Remove-Tool -PlanName $planName
Remove-Link -PlanName $planName
Remove-Cli -PlanName $planName
Remove-Plan -PlanName $planName
