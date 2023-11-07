param(
    [Parameter(Position = 0)]
    [array]$Arguments
)

function Add-Link($PlanName) {
    if (!$PlanName) {
        return
    }

    $folder = Get-PlanPackageFolder -PlanName $PlanName
    $shortcutTarget = Get-PlanPackageShortcutTarget -PlanName $PlanName
    $shortcutName = Get-PlanPackageShortcutName -PlanName $PlanName

    New-Shortcut -TargetPath $Env:TOOLBOX_APPS\$folder$shortcutTarget -ShortcutName $shortcutName
}

function Add-Cli($PlanName) {
    if (!$PlanName) {
        return
    }
    
    $newCliName = Get-PlanCli -PlanName $PlanName

    if ((Test-Path "$Env:TOOLBOX_PLANS\$PlanName\bin\cli.ps1") -and $newCliName) {
        Write-Task "Adding custom '$newCliName' CLI in Toolbox"

        Write-Host "Creating '$newCliName' bat file."

        New-Item -Path "$Env:TOOLBOX_BIN\$newCliName.bat" -ItemType File -Force -ErrorAction Stop | Out-Null
        Add-Content -Path "$Env:TOOLBOX_BIN\$newCliName.bat" -Value "@echo OFF"
        Add-Content -Path "$Env:TOOLBOX_BIN\$newCliName.bat" -Value "set current_location=%~dp0"
        Add-Content -Path "$Env:TOOLBOX_BIN\$newCliName.bat" -Value "set command=%*"
        $targetPath = "powershell -NoProfile -ExecutionPolicy bypass -File "
        $targetPath += '"'
        $targetPath += "%current_location%..\plans\$PlanName\bin\cli.ps1"
        $targetPath += '"'
        $targetPath += " %command%"
        Add-Content -Path "$Env:TOOLBOX_BIN\$newCliName.bat" -Value $targetPath
    }
}

function Install-Plan($Arguments) {
    $planName = Get-FirtArgument -Arguments $Arguments
    $otherOptions = Get-RemainingArguments -Arguments $Arguments

    foreach ($dependency in (Get-PlanDependencies -PlanName $planName) ) {
        Install-Plan $dependency.name
    }

    if (Test-Path "$Env:TOOLBOX_PLANS\$planName\bin\install.ps1") {
        ."$Env:TOOLBOX_PLANS\$planName\bin\install.ps1" $otherOptions
    }

    Add-Link -PlanName $planName
    Add-Cli -PlanName $planName
}

function Save-PlanDependencies($Arguments, $PlansTemporaryDirectory) {
    if (!$Arguments) {
        throw "The installation pre-check has failed due to a plan name missing in dependencies."
    }

    $planName = Get-FirtArgument -Arguments $Arguments
    $gitRepository = Get-PlanGitRepository -PlanName $planName

    if (!$gitRepository) {
        throw "The installation pre-check has failed due to a missing Git repository in Toolbox configuration."
    }
    
    Write-Task "Downloading '$planName' from $gitRepository"

    if (!(Test-PlanConfig -PlanName $planName)) {
        Start-Git @("-C", $PlansTemporaryDirectory, "clone", $gitRepository, $planName)

        if (!(Test-Path "$PlansTemporaryDirectory\$planName\plan.json")) {
            throw "The installation pre-check has failed due to a failure while downloading '$planName' plan. The installation has been aborted."
        }
    }
    else {
        Write-Host "'$planName' plan has been already downloaded. Skipping download."
    }

    foreach ($dependency in (Get-PlanDependencies -PlanName $planName -PlansTemporaryDirectory $PlansTemporaryDirectory) ) {
        Save-PlanDependencies -Arguments $dependency.name -PlansTemporaryDirectory $PlansTemporaryDirectory
    }
}

function Test-PlanConflicts($PlansTemporaryDirectory) {
    [array]$localPlans = Get-ChildItem $Env:TOOLBOX_PLANS -ErrorAction Stop
    [array]$localPlans += Get-ChildItem $PlansTemporaryDirectory -ErrorAction Stop

	$cursor = 0
	
    foreach ($localPlan in $localPlans) {
        for ($i = ($cursor + 1); $i -lt ($localPlans.Count); $i++) {
            $currentPlanName = $localPlan.Name
            $nextPlanName = $localPlans[$i].Name

            $folderCurrent = Get-PlanPackageFolder -PlanName $currentPlanName -PlansTemporaryDirectory $PlansTemporaryDirectory
            $shortcutCurrent = Get-PlanPackageShortcutName -PlanName $currentPlanName -PlansTemporaryDirectory $PlansTemporaryDirectory
            $cliCurrent = Get-PlanCli -PlanName $currentPlanName -PlansTemporaryDirectory $PlansTemporaryDirectory

            $folderNext = Get-PlanPackageFolder -PlanName $nextPlanName -PlansTemporaryDirectory $PlansTemporaryDirectory
            $shortcutNext = Get-PlanPackageShortcutName -PlanName $nextPlanName -PlansTemporaryDirectory $PlansTemporaryDirectory
            $cliNext = Get-PlanCli -PlanName $nextPlanName -PlansTemporaryDirectory $PlansTemporaryDirectory

            if ($folderCurrent -and $folderNext -and ($folderCurrent -eq $folderNext)) {
                throw "The installation pre-check has failed due to a folder name conflict between '$currentPlanName' and '$nextPlanName' plans."
            }

            if ($shortcutCurrent -and $shortcutNext -and ($shortcutCurrent -eq $shortcutNext)) {
                throw "The installation pre-check has failed due to a shortcut name conflict between '$currentPlanName' and '$nextPlanName' plans."
            }

            if ($cliCurrent -and $cliNext -and ($cliCurrent -eq $cliNext)) {
                throw "The installation pre-check has failed due to a CLI name conflict between '$currentPlanName' and '$nextPlanName' plans."
            }
        }
		
		$cursor++
    }
}

if (!$Arguments) {
    Write-Host "A plan name must be provided.`n" -ForegroundColor Yellow
    Write-Help
    return
}

$planName = Get-FirtArgument -Arguments $Arguments
$gitRepository = Get-PlanGitRepository -PlanName $planName

if (!$gitRepository) {
    Write-Host "The plan '$planName' doesn't exist in Toolbox. Try with another name." -ForegroundColor Yellow
    Write-Host "Use 'toolbox list' to see all available plans for installation."
    return
}

$temporaryGuid = '{' + [guid]::NewGuid().ToString() + '}'
$plansTemporaryDirectory = "$Env:TEMP\$temporaryGuid"
New-Item -ItemType Directory -Path $plansTemporaryDirectory -ErrorAction SilentlyContinue | Out-Null
Save-PlanDependencies -Arguments $Arguments -PlansTemporaryDirectory $plansTemporaryDirectory
Test-PlanConflicts -PlansTemporaryDirectory $plansTemporaryDirectory
Copy-Item -Path "$plansTemporaryDirectory\*" -Destination $Env:TOOLBOX_PLANS -Recurse
Install-Plan -Arguments $Arguments
