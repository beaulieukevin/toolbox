."$Env:TOOLBOX_HOME\scripts\core\proxy-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\git-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\release-module.ps1"

$releaseContent = @"
"@

Write-Task "Pulling latest updates of 'toolbox' core"
$oldAppConfig = Get-AppConfig
$oldToolboxVersion = Get-ToolboxVersion
Start-Git @("-C", "$Env:TOOLBOX_HOME", "pull")
$newAppConfig = Get-AppConfig
$newToolboxVersion = Get-ToolboxVersion

if ($oldToolboxVersion -ne $newToolboxVersion) {
    $releaseContent += Get-ToolboxReleaseContent -ToolboxNewVersion $newToolboxVersion
}

if ($oldAppConfig.version -ne $newAppConfig.version) {
    $params = @{}
    
    if ($oldAppConfig.toolbox.docsUrl -ne $newAppConfig.toolbox.docsUrl) {
        $params["DocsUrlChanged"] = $true
    }

    if ($oldAppConfig.toolbox.autoUpdate -ne $newAppConfig.toolbox.autoUpdate) {
        $params["AutoUpdateChanged"] = $true
    }

    if ((($oldAppConfig.git.systemConfig | ConvertTo-Json -Compress) -ne ($newAppConfig.git.systemConfig | ConvertTo-Json -Compress)) -or (($oldAppConfig.git.globalConfig | ConvertTo-Json -Compress) -ne ($newAppConfig.git.globalConfig | ConvertTo-Json -Compress))) {
        $params["GitConfigChanged"] = $true
    }

    if (($oldAppConfig.proxy.config | ConvertTo-Json -Compress) -ne ($newAppConfig.proxy.config | ConvertTo-Json -Compress)) {
        $params["ProxyConfigChanged"] = $true
    }

    $releaseContent += Get-ConfigReleasecontent -ConfigNewVersion $newAppConfig.version @params
}

$addedPlans = @()
foreach ($newPlanName in $newAppConfig.plans.PSObject.Properties.Name) {
    if (!($oldAppConfig.plans.$newPlanName)) {
        $addedPlans += $newPlanName
    }
}

$deprecatedPlans = @()
$planItems = Get-ChildItem -Path "$Env:TOOLBOX_HOME\local\plans" -ErrorAction SilentlyContinue
foreach ($oldPlanName in $oldAppConfig.plans.PSObject.Properties.Name) {
    if (!($newAppConfig.plans.$oldPlanName)) {
        $isInstalled = $false
        foreach ($planItem in $planItems) {
            $planName = $planItem.Name
            if ($oldPlanName -eq $planItem) {
                $isInstalled = $true
            }
        }

        if ($isInstalled) {
            $deprecatedPlans += $oldPlanName
        }
    }
}

$updatedPlans = @()
$planItems = Get-ChildItem -Path "$Env:TOOLBOX_HOME\local\plans" -ErrorAction SilentlyContinue
foreach ($planItem in $planItems) {
    $planName = $planItem.Name
        
    Write-Task "Pulling latest updates of '$planName' plan"
    $oldPlanConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    Start-Git @("-C", "$Env:TOOLBOX_HOME\local\plans\$planName", "pull")
    $newPlanConfig = Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    if ($oldPlanConfig.version -ne $newPlanConfig.version) {
        $updatedPlans += $planName
    }
}

if ($addedPlans -or $updatedPlans -or $deprecatedPlans) {
    $releaseContent += Get-PlansReleaseContent -AddedPlans $addedPlans -UpdatedPlans $updatedPlans -DeprecatedPlans $deprecatedPlans
}

if ($oldAppConfig.git.version -ne $newAppConfig.git.version) {
    $releaseContent += Get-GitReleaseContent -GitNewVersion $newAppConfig.git.version
}

if ($oldAppConfig.proxy.version -ne $newAppConfig.proxy.version) {
    $releaseContent += Get-ProxyReleaseContent -ProxyNewVersion $newAppConfig.proxy.version
}

Write-Task "Updating global Toolbox configuration coming from your company"

if ($oldAppConfig.git.version -ne $newAppConfig.git.version) {
    Write-Host "A new version of Git is available, updating it to the latest version"
    Expand-Git
    Set-GitSystemConfig
}

if (($oldAppConfig.git.systemConfig | ConvertTo-Json -Compress) -ne ($newAppConfig.git.systemConfig | ConvertTo-Json -Compress)) {
    Write-Host "Updating Git system config"
    Set-GitSystemConfig -OnlyConfigFile
}

if (($oldAppConfig.git.globalConfig | ConvertTo-Json -Compress) -ne ($newAppConfig.git.globalConfig | ConvertTo-Json -Compress)) {
    Write-Host "Updating Git global config"
    Set-GitGlobalConfig -OnlyConfigFile
}

if ($oldAppConfig.proxy.version -ne $newAppConfig.proxy.version) {
    Write-Host "A new version of your local proxy is available, updating it to the latest version"
    Update-Proxy
}

if (($oldAppConfig.proxy.config | ConvertTo-Json -Compress) -ne ($newAppConfig.proxy.config | ConvertTo-Json -Compress)) {
    Write-Host "Updating local proxy config"
    Set-ProxyConfig
}

if ($oldAppConfig.toolbox.autoUpdate -ne $newAppConfig.toolbox.autoUpdate) {
    Write-Host "Updating Toolbox CLI auto update feature"

    Unregister-ToolboxCLIAutoUpdate

    $appConfig = Get-AppConfig
    $toolboxAutoUpdate = $appConfig.toolbox.autoUpdate

    if (($null -ne $toolboxAutoUpdate) -and $toolboxAutoUpdate) {
        Register-ToolboxCLIAutoUpdate
    }
}

Send-ReleaseNotesMailMessage -ReleaseContent $releaseContent

