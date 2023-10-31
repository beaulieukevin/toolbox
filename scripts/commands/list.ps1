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
                Write-Host "$planName@$planVersion" -ForegroundColor Yellow
                Write-Host "  The plan is no longer supported. Uninstall it using: toolbox uninstall $planName"
            }
            else {
                $readmeUrl = Get-MarkdownFileUrlFromRepository -GitRepository $gitRepository -MarkdownType "README"
                Write-Host "$planName@$planVersion" -ForegroundColor Green
                Write-Host "  More info: $readmeUrl"
            }
        }
        else {
            Write-Host $planName -ForegroundColor Red
            Write-Host "  The plan is corrupted."
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
            Write-Host $planName -ForegroundColor Blue
            Write-Host "  More info: $readmeUrl"
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
