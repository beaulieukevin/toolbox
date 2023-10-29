function Write-InstalledPlans {
    Write-Task "Plans installed locally"

    $downloadedPlanDirs = Get-ChildItem "$Env:TOOLBOX_HOME\local\plans" -ErrorAction SilentlyContinue

    if ($downloadedPlanDirs.Count -eq 0) {
        Write-Host "No plan has been installed."
        return
    }

    $appConfig = Get-AppConfig
    $supportEmail = $appConfig.organization.supportEmail

    foreach ($downloadedPlanDir in $downloadedPlanDirs) {
        $planName = $downloadedPlanDir.Name
        if (Test-Path "$Env:TOOLBOX_HOME\local\plans\$planName\plan.json") {
            $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$planName\plan.json" -ErrorAction Stop | ConvertFrom-Json
            $planVersion = $planConfig.version
            $plans = $appConfig.plans
            $gitRepository = $plans.$planName.gitRepository
            if (!$gitRepository) {
                Write-Host "$planName@$planVersion > The plan is no longer part of Toolbox. Uninstall it by using: toolbox uninstall $planName" -ForegroundColor Yellow
            }
            else {
                $readmeUrl = Get-MarkdownFileUrlFromRepository -GitRepository $gitRepository -MarkdownType "README"
                Write-Host "$planName@$planVersion > More info: $readmeUrl"
            }
        }
        else {
            Write-Host "$planName > The plan is corrupted. Contact $supportEmail for support." -ForegroundColor Red
        }
    }
}

function Write-RemotePlans {
    Write-Task "Plans available remotely for installation"

    $appConfig = Get-AppConfig
    $plansAvailableRemotely = 0

    foreach ($planName in $appConfig.plans.PSObject.Properties.Name) {
        if (!(Test-Path "$Env:TOOLBOX_HOME\local\plans\$planName")) {
            $plans = $appConfig.plans
            $gitRepository = $plans.$planName.gitRepository
            $plansAvailableRemotely++

            $readmeUrl = Get-MarkdownFileUrlFromRepository -GitRepository $gitRepository -MarkdownType "README"
            Write-Host "$planName > More info: $readmeUrl"
        }
    }

    if ($plansAvailableRemotely -eq 0) {
        Write-Host "No other plan is available for installation."
    }
}

Write-InstalledPlans
Write-Host ""
Write-RemotePlans
