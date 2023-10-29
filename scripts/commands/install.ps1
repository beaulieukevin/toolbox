param(
    [Parameter(Position = 0)]
    [array]$Options
)

function Add-Link($PlanName) {
    if (!$PlanName) {
        return
    }

    $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    $folder = $planConfig.package.folder
    $shortcutTarget = $planConfig.package.shortcutTarget
    $shortcutName = $planConfig.package.shortcutName

    New-Shortcut -TargetPath $Env:TOOLBOX_APPS\$folder$shortcutTarget -ShortcutName $shortcutName
}

function Add-Cli($PlanName) {
    if (!$PlanName) {
        return
    }
    
    $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    $newCliName = $planConfig.cli

    if ((Test-Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\bin\cli.ps1") -and $newCliName) {
        Write-Task "Adding custom '$newCliName' CLI in Toolbox"

        $items = Get-ChildItem -Path "$Env:TOOLBOX_HOME\local\bin" -ErrorAction Stop
        foreach ($item in $items) {
            $currentCliName = $item.BaseName
            $currentCliNameExtension = $item.Name
            if ($currentCliName -eq $newCliName) {
                $content = Get-Content "$Env:TOOLBOX_HOME\local\bin\$currentCliNameExtension"
                $cliRelatedPlan = $content[3]
                $cliRelatedPlan = $cliRelatedPlan.Replace('powershell -NoProfile -ExecutionPolicy bypass -File "%current_location%..\plans\', "")
                $cliRelatedPlan = $cliRelatedPlan.Replace('\bin\cli.ps1" %command%', "")

                if ($PlanName -ne $cliRelatedPlan) {
                    Write-CliWarning "Cannot add '$newCliName' CLI as there is already an existing CLI with the same alias name."
                    Write-CliWarning "The existing CLI belongs to '$cliRelatedPlan' plan."
                    Write-CliWarning "Please contact the responsible of '$PlanName' and '$cliRelatedPlan' plans to solve the issue."
                    return
                }
            }
        }

        Write-Host "Creating '$newCliName' bat file."

        New-Item -Path "$Env:TOOLBOX_HOME\local\bin\$newCliName.bat" -ItemType File -Force -ErrorAction Stop | Out-Null
        Add-Content -Path "$Env:TOOLBOX_HOME\local\bin\$newCliName.bat" -Value "@echo OFF"
        Add-Content -Path "$Env:TOOLBOX_HOME\local\bin\$newCliName.bat" -Value "set current_location=%~dp0"
        Add-Content -Path "$Env:TOOLBOX_HOME\local\bin\$newCliName.bat" -Value "set command=%*"
        $targetPath = "powershell -NoProfile -ExecutionPolicy bypass -File "
        $targetPath += '"'
        $targetPath += "%current_location%..\plans\$PlanName\bin\cli.ps1"
        $targetPath += '"'
        $targetPath += " %command%"
        Add-Content -Path "$Env:TOOLBOX_HOME\local\bin\$newCliName.bat" -Value $targetPath
    }
}

function Install-Plan($Options) {
    if (!$Options) {
        Write-Host "A plan name must be provided."
        Write-Host ""
        Write-Help
        return
    }

    $planName = Get-CliCommand $Options
    $otherOptions = Get-CliOptions $Options

    $appConfig = Get-AppConfig
    $plans = $appConfig.plans
    $gitRepository = $plans.$planName.gitRepository

    if (!$gitRepository) {
        Write-Host "The plan '$planName' is not listed in Toolbox configuration. Try again with another plan name."
        Write-Host "Run the command below to see plans available for download:"
        Write-Command "toolbox list"
        return
    }
    
    Write-Task "Downloading '$planName' from $gitRepository"

    if (Test-Path -Path "$Env:TOOLBOX_HOME\local\plans\$planName") {
        Write-Host "The plan '$planName' has been already downloaded. Skipping download."
        Write-Host "You can update the existing plans by running:"
        Write-Command "toolbox update"
    }
    else {
        Start-Git @("-C", "$Env:TOOLBOX_HOME\local\plans", "clone", $gitRepository, $planName)

        if (!(Test-Path -Path "$Env:TOOLBOX_HOME\local\plans\$planName")) {
            Write-CliWarning "The plan '$planName' was not found in the remote repository."
            Write-CliWarning "Therefore the installation has been aborted."
            return
        }
    }

    $planConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$planName\plan.json" -ErrorAction Stop | ConvertFrom-JSON

    foreach ($dependency in $planConfig.dependencies ) {
        Install-Plan $dependency.name
    }

    if (Test-Path "$Env:TOOLBOX_HOME\local\plans\$planName\bin\install.ps1") {
        Write-Task "Executing '$planName' plan installation"
        ."$Env:TOOLBOX_HOME\local\plans\$planName\bin\install.ps1" $otherOptions
    }

    Add-Link -PlanName $planName
    Add-Cli -PlanName $planName
}

Install-Plan $Options
