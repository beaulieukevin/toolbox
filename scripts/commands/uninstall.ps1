param(
    [Parameter(Position = 0)]
    [array]$Options
)

function Remove-Link($PlanName) {
    if (!$PlanName) {
        return
    }
    
    $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    $shortcutName = $planConfig.package.shortcutName

    if (!$shortcutName) {
        return
    }
    
    Write-Host "Removing '$PlanName' shortcut from your desktop."

    Remove-Shortcut -ShortcutName $shortcutName

    Write-Host "Successfully removed '$PlanName' shortcut from your desktop."
}

function Remove-Tool($PlanName) {
    if (!$PlanName) {
        return
    }

    $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    $folderName = $planConfig.package.folder

    if (!$folderName) {
        return
    }
    
    Write-Host "Removing '$PlanName' tool from Toolbox."

    Remove-Directory -Path "$Env:TOOLBOX_APPS\$folderName"

    Write-Host "Successfully removed '$PlanName' tool from Toolbox."
}

function Remove-Cli($PlanName) {
    if (!$PlanName) {
        return
    }

    $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    $cliName = $planConfig.cli

    if (!$cliName) {
        return
    }
    
    Write-Host "Removing '$cliName' CLI from Toolbox."

    Remove-Item -Path "$Env:TOOLBOX_HOME\local\bin\$cliName.bat" -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Successfully removed '$cliName' CLI from Toolbox."
}

function Remove-Plan($PlanName) {
    if (!$PlanName) {
        return
    }

    Write-Host "Removing '$PlanName' plan from Toolbox."

    Remove-Directory -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName"

    Write-Host "Successfully removed '$PlanName' plan from Toolbox."
}

if (!$Options) {
    Write-Host "You must provide a plan name to uninstall."
    Write-Host ""
    Write-Help
    return
}

$planName = Get-CliCommand $Options
    
if (!(Test-Path -Path "$Env:TOOLBOX_HOME\local\plans\$planName\plan.json")) {
    Write-Host "The plan '$planName' is not downloaded via Toolbox."
    return
}

Write-Task "Uninstalling '$planName' from Toolbox"

Remove-Link -PlanName $planName
Remove-Tool -PlanName $planName
Remove-Cli -PlanName $planName
Remove-Plan -PlanName $planName
