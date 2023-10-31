param(
    [Parameter(Position = 0)]
    [array]$Options
)

."$Env:TOOLBOX_HOME\scripts\core\analytics-module.ps1"

$analytics = Get-ToolboxAnalytics

if (!$analytics) {
    Write-Host "Analytics have not been activated by your organization."
    return
}

$validOptions = @("on", "off", "status")

if (!$Options) {
    Write-Host "A valid argument must be provided. Only '$($validOptions -join (', '))' can be used.`n" -ForegroundColor Yellow
    Write-Help
    return
}

$selectionMode = Get-FirtArgument $Options
    
if ($selectionMode -notin $validOptions) {
    Write-Host "A valid argument must be provided. Only '$($validOptions -join (', '))' can be used.`n" -ForegroundColor Yellow
    Write-Help
    return
}

if ($selectionMode -ceq "on") {
    Set-AnalyticsConsent -NoPrompt
    return
}

if ($selectionMode -ceq "off") {
    Set-AnalyticsConsent
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
