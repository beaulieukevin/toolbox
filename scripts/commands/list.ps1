function Write-InstalledPlans {
    Write-Task "Plans installed locally"

    $localPlans = Get-ChildItem $Env:TOOLBOX_PLANS -ErrorAction SilentlyContinue

    if (!$localPlans) {
        Write-Host "No plan has been installed."
        return
    }

    foreach ($localPlan in $localPlans) {
        $planName = $localPlan.Name
        if (Test-PlanConfig -PlanName $planName) {
            $planVersion = Get-PlanVersion -PlanName $planName
            $gitRepository = Get-PlanGitRepository -PlanName $planName
            if (!$gitRepository) {
                Write-Host "$planName@$planVersion > The plan is no longer part of Toolbox. Uninstall it using: toolbox uninstall $planName" -ForegroundColor Yellow
            }
            else {
                $readmeUrl = Get-MarkdownFileUrlFromRepository -GitRepository $gitRepository -MarkdownType "README"
                Write-Host "$planName@$planVersion > More info: $readmeUrl" -ForegroundColor Green
            }
        }
        else {
            Write-Host "$planName > The plan is corrupted." -ForegroundColor Red
        }
    }
}

function Write-RemotePlans {
    Write-Task "Plans available remotely for installation"

    $companyPlans = Get-CompanyPlans
    $plansNotInstalled = 0

    foreach ($planName in $companyPlans.PSObject.Properties.Name) {
        if (!(Test-PlanConfig -PlanName $planName)) {
            $gitRepository = Get-PlanGitRepository -PlanName $planName
            $readmeUrl = Get-MarkdownFileUrlFromRepository -GitRepository $gitRepository -MarkdownType "README"
            Write-Host "$planName > More info: $readmeUrl"
            $plansNotInstalled++
        }
    }

    if (!$plansNotInstalled) {
        Write-Host "No other plan is available for installation."
    }
}

Write-InstalledPlans
Write-Host ""
Write-RemotePlans
