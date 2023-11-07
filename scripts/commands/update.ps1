."$Env:TOOLBOX_HOME\scripts\core\analytics-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\git-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\proxy-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\release-module.ps1"

$releaseContent = @"
"@

Write-Task "Pulling latest updates of 'toolbox' core"
$oldCompanyConfig = Get-CompanyConfig
$oldToolboxVersion = Get-ToolboxVersion
Start-Git @("-C", "$Env:TOOLBOX_HOME", "pull")
$newCompanyConfig = Get-CompanyConfig
$newToolboxVersion = Get-ToolboxVersion

if ($oldToolboxVersion -ne $newToolboxVersion) {
    $releaseContent += Get-ToolboxReleaseContent -ToolboxNewVersion $newToolboxVersion
}

if ($oldCompanyConfig.version -ne $newCompanyConfig.version) {
    $params = @{}
    
    if ($oldCompanyConfig.toolbox.docsUrl -ne $newCompanyConfig.toolbox.docsUrl) {
        $params["DocsUrlChanged"] = $true
    }

    if ($oldCompanyConfig.toolbox.autoUpdate -ne $newCompanyConfig.toolbox.autoUpdate) {
        $params["AutoUpdateChanged"] = $true
    }

    if ($oldCompanyConfig.organization.supportEmail -ne $newCompanyConfig.organization.supportEmail) {
        $params["SupportEmailChanged"] = $true
    }

    $releaseContent += Get-ConfigReleasecontent -ConfigNewVersion $newCompanyConfig.version @params
}

$addedPlans = @()
foreach ($newPlanName in $newCompanyConfig.plans.PSObject.Properties.Name) {
    if (!($oldCompanyConfig.plans.$newPlanName)) {
        $addedPlans += $newPlanName
    }
}

$deprecatedPlans = @()
$planItems = Get-ChildItem -Path $Env:TOOLBOX_PLANS -ErrorAction SilentlyContinue
foreach ($oldPlanName in $oldCompanyConfig.plans.PSObject.Properties.Name) {
    if (!($newCompanyConfig.plans.$oldPlanName)) {
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
$planItems = Get-ChildItem -Path $Env:TOOLBOX_PLANS -ErrorAction SilentlyContinue
foreach ($planItem in $planItems) {
    $planName = $planItem.Name
        
    Write-Task "Pulling latest updates of '$planName' plan"
    $oldPlanConfig = Get-Content -Path "$Env:TOOLBOX_PLANS\$planName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    Start-Git @("-C", "$Env:TOOLBOX_PLANS\$planName", "pull")
    $newPlanConfig = Get-Content -Path "$Env:TOOLBOX_PLANS\$planName\plan.json" -ErrorAction Stop | ConvertFrom-JSON
    if ($oldPlanConfig.version -ne $newPlanConfig.version) {
        $updatedPlans += $planName
    }
}

if ($addedPlans -or $updatedPlans -or $deprecatedPlans) {
    $releaseContent += Get-PlansReleaseContent -AddedPlans $addedPlans -UpdatedPlans $updatedPlans -DeprecatedPlans $deprecatedPlans
}

if ($oldCompanyConfig.git.version -ne $newCompanyConfig.git.version) {
    $releaseContent += Get-GitReleaseContent -GitNewVersion $newCompanyConfig.git.version
}

if ($oldCompanyConfig.proxy.version -ne $newCompanyConfig.proxy.version) {
    $releaseContent += Get-ProxyReleaseContent -ProxyNewVersion $newCompanyConfig.proxy.version
}

Write-Task "Updating global Toolbox configuration coming from your company"

if ($oldCompanyConfig.git.version -ne $newCompanyConfig.git.version) {
    Write-Host "A new version of Git is available, updating it to the latest version"
    Expand-Git
    Set-GitSystemConfig
    Set-GitGlobalConfig -NoPrompt
}

if (($oldCompanyConfig.git.systemConfig | ConvertTo-Json -Compress) -ne ($newCompanyConfig.git.systemConfig | ConvertTo-Json -Compress)) {
    Write-Host "Updating Git system config"
    Set-GitSystemConfig
}

if (($oldCompanyConfig.git.globalConfig | ConvertTo-Json -Compress) -ne ($newCompanyConfig.git.globalConfig | ConvertTo-Json -Compress)) {
    Write-Host "Updating Git global config"
    Set-GitGlobalConfig -NoPrompt
}

if ($oldCompanyConfig.proxy.version -ne $newCompanyConfig.proxy.version) {
    Write-Host "A new version of your local proxy is available, updating it to the latest version"
    Update-Proxy
}

if (($oldCompanyConfig.proxy.config | ConvertTo-Json -Compress) -ne ($newCompanyConfig.proxy.config | ConvertTo-Json -Compress)) {
    Write-Host "Updating local proxy config"
    Update-ProxyConfig
}

if ($oldCompanyConfig.toolbox.autoUpdate -ne $newCompanyConfig.toolbox.autoUpdate) {
    Write-Host "Updating Toolbox auto update feature"

    Unregister-ToolboxAutoUpdate

    $toolboxAutoUpdate = Get-ToolboxAutoUpdateConfig

    if (($null -ne $toolboxAutoUpdate) -and $toolboxAutoUpdate) {
        Register-ToolboxAutoUpdate
    }
}

Send-ReleaseNotesMailMessage -ReleaseContent $releaseContent
