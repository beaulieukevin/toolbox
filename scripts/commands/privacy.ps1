param(
    [Parameter(Position = 0)]
    [array]$Options
)

."$Env:TOOLBOX_HOME\scripts\core\analytics-module.ps1"

$appConfig = Get-AppConfig
$analytics = $appConfig.analytics

if (!$analytics) {
    Write-Host "Analytics have not been activated by your organization."
    return
}

$validOptions = @("on", "off", "status")

if (!$Options) {
    Write-Host "A valid argument must be provided. Only '$validOptions' can be used."
    Write-Host ""
    Write-Help
    return
}

$selectionMode = Get-CliCommand $Options
    
if (!($validOptions -ccontains $selectionMode)) {
    Write-Host "A valid argument must be provided. Only '$validOptions' can be used."
    Write-Host ""
    Write-Help
    return
}

if ($selectionMode -ceq "on") {
    Show-AnalyticsConsentQuestion -InlineIsAnonymous $true
    return
}

if ($selectionMode -ceq "off") {
    Show-AnalyticsConsentQuestion
    return
}

if ($selectionMode -ceq "status") {
    $userConfig = Get-UserConfig
    $areAnalyticsAnonymous = $userConfig.areAnalyticsAnonymous

    if ($areAnalyticsAnonymous) {
        Write-Host "Analytics are captured anonymously"
    }
    else {
        Write-Host "Analytics are captured with your username ($Env:USERNAME)"
    }
}
