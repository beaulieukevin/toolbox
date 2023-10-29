function Initialize-Analytics {
    $appConfig = Get-AppConfig
    $analytics = $appConfig.analytics

    if (!$analytics) {
        return
    }

    Show-AnalyticsConsentQuestion
}

function Show-AnalyticsConsentQuestion($InlineIsAnonymous) {
    $appConfig = Get-AppConfig
    $organizationName = $appConfig.organization.name

    if ($null -eq $InlineIsAnonymous) {
        Write-Task "$organizationName has activated analytics on Toolbox. Please read the terms and conditions below:"
        Write-HostAsBot "In order to improve $organizationName's developer experience,"
        Write-HostAsBot "we will capture your usage of Toolbox through analytics."
        Write-Host ""
        Write-HostAsBot "By accepting the terms and conditions the following data will be shared with the platform team:"
        Write-HostAsBot " - Your username ($Env:USERNAME), to contact you and gather your feedback"
        Write-HostAsBot " - The command and options you are using in order to analyze global usage"
        Write-HostAsBot " - The timestamp of each command and options you have used to analyze usage evolution"
        Write-HostAsBot " - All errors you will encounter in order to improve Toolbox"
        Write-Host ""
        Write-HostAsBot "All these data will remain within $organizationName and won't be shared to any third parties."
        Write-Host ""
        Write-HostAsBot "If you don't accept the terms and conditions, your username will be anonymized."
        Write-HostAsBot "And $organizationName won't have the possibility to contact you to gather your feedback."
        Write-Host ""

        while ($true) {
            $userInput = Read-Host "Do you accept to share your username ($Env:USERNAME) with $organizationname [Y/n]?"
            if ($userInput -ceq "Y") {
                $isAnonymized = $false
                break
            }
            if ($userInput -ceq "n") {
                $isAnonymized = $true
                break
            }
        }
    }
    else {
        $isAnonymized = $InlineIsAnonymous
    }

    $userConfig = Get-UserConfig
    $userConfig.areAnalyticsAnonymous = $isAnonymized

    Set-UserConfig $userConfig

    if ($isAnonymized) {
        Write-Host "Analytics will be captured anonymously"
    }
    else {
        Write-Host "Analytics will be captured with your username ($Env:USERNAME)"
    }
}
