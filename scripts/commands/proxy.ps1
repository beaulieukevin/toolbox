param(
    [Parameter(Position = 0)]
    [array]$Options
)

."$Env:TOOLBOX_HOME\scripts\core\proxy-module.ps1"

$appConfig = Get-AppConfig
$proxy = $appConfig.proxy

if (!$proxy) {
    Write-Host "Local proxy has not been activated by your organization."
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

$address = [System.Net.WebProxy]::GetDefaultProxy().Address

if (!$address) {
    Write-Host "No proxy has been detected in your organization."
    return
}

if ($selectionMode -ceq "on") {
    Start-Proxy
    return
}

if ($selectionMode -ceq "off") {
    Stop-Proxy
    return
}

if ($selectionMode -ceq "status") {
    $proxyProcessesCount = Get-ProxyProcesses
    if ($proxyProcessesCount -eq 0) {
        Write-Host "Your local proxy is not running."
    }
    else {
        Write-Host "Your local proxy is running using $proxyProcessesCount instances."
    }
}
