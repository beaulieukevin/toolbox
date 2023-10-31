function Write-Help {
    Write-Host "Usage" -ForegroundColor White
    Write-Host "toolbox <command> [<args>]"
    Write-Host ""
    Write-Host "Commands to get Toolbox information" -ForegroundColor White
    Write-Host "docs                          : Open Toolbox manual page on your default browser"
    Write-Host "help                          : Get help from Toolbox"
    Write-Host "version                       : Get Toolbox version"
    Write-Host ""
    Write-Host "Commands to manage Toolbox" -ForegroundColor White
    Write-Host "privacy on|off|status         : Manage analytics privacy"
    Write-Host "proxy on|off|status           : Start or stop the configured local proxy"
    Write-Host "update                        : Update Toolbox and all downloaded plans"
    Write-Host ""
    Write-Host "Commands to manage plans and tools" -ForegroundColor White
    Write-Host "install <args>                : Download the target plan and install its associated tool"
    Write-Host "list                          : List all plans available remotely and downloaded locally"
    Write-Host "uninstall <args>              : Uninstall the target plan and its associated tool"
}

function Write-Task($Text) {
    Write-Host "==> " -ForegroundColor DarkMagenta -NoNewline
    Write-Host $Text -ForegroundColor White
}

function Write-HostAsBot($Text) {
    if (!$Text) {
        return
    }

    $textArray = $Text.ToCharArray()
    $totalNumberOfChar = $textArray.Count
    $currentCharIndex = 0

    foreach ($char in $textArray) {
        $currentCharIndex++

        if ($currentCharIndex -ne $totalNumberOfChar) {
            Write-Host $char -NoNewline
        }
        else {
            Write-Host $char
        }
		
        Start-Sleep -Milliseconds 10
    }
}

function Write-Command($Text) {
    Write-Host "  $Text" -ForegroundColor White
}

function Write-CliWarning($Text) {
    Write-Host "warning: $Text" -ForegroundColor Yellow
}

function Write-CliError($Text) {
    Write-Host "error: $Text" -ForegroundColor Red
}

function Get-AppConfig {
    return Get-Content -Path "$Env:TOOLBOX_HOME\config.json" -ErrorAction Stop | ConvertFrom-JSON
}

function Get-CompanyConfig {
    return Get-Content -Path "$Env:TOOLBOX_HOME\config.json" -ErrorAction Stop | ConvertFrom-JSON
}

function Get-CompanyEmailDomain {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.organization.emailDomain
}

function Get-CompanyProxyConfig {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.proxy
}

function Get-CompanyEnvironmentVariables {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.environmentVariables
}

function Get-CompanyDocsUrl {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.toolbox.docsUrl
}

function Get-CompanyPlans {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.plans
}

function Get-PlanConfig($PlanName) {
    return Get-Content -Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json" -ErrorAction Stop | ConvertFrom-Json
}

function Get-PlanVersion($PlanName) {
    $planConfig = Get-PlanConfig -PlanName $planName
    return $planConfig.version
}

function Get-PlanGitRepository($PlanName) {
    $companyPlans = Get-CompanyPlans
    return $companyPlans.$PlanName.gitRepository
}

function Test-PlanConfig($PlanName) {
    return Test-Path "$Env:TOOLBOX_HOME\local\plans\$PlanName\plan.json"
}

function Get-ToolboxAutoUpdateConfig {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.toolbox.autoUpdate
}

function Get-ToolboxVersion {
    $toolbox = Get-Content -Path "$Env:TOOLBOX_HOME\toolbox.json" -ErrorAction Stop | ConvertFrom-JSON
    return $toolbox.version
}

function Get-UserConfig {
    if (!(Test-Path "$Env:TOOLBOX_HOME\local\config.json")) {
        New-Item -ItemType Directory -Path "$Env:TOOLBOX_HOME\local" -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType File -Path "$Env:TOOLBOX_HOME\local\config.json"  -ErrorAction SilentlyContinue | Out-Null

        $initContent = @{
            "userUuid"              = [guid]::NewGuid().Guid;
            "areAnalyticsAnonymous" = $true;
        }

        $content = Get-Content -Path "$Env:TOOLBOX_HOME\local\config.json" -ErrorAction Stop | ConvertFrom-JSON
        $content += $initContent
        $content | ConvertTo-JSON | Set-Content "$Env:TOOLBOX_HOME\local\config.json"
    }

    return Get-Content -Path "$Env:TOOLBOX_HOME\local\config.json" -ErrorAction Stop | ConvertFrom-JSON
}

function Set-UserConfig($Config) {
    $Config | ConvertTo-JSON | Set-Content "$Env:TOOLBOX_HOME\local\config.json" -ErrorAction Stop
}

function Send-ToolboxAnalytics($Command, $Arguments, $ScriptError) {
    try {
        $appConfig = Get-AppConfig
        $analytics = $appConfig.analytics

        if (!$analytics) {
            return
        }

        $userConfig = Get-UserConfig
        $areAnalyticsAnonymous = $userConfig.areAnalyticsAnonymous

        if ($areAnalyticsAnonymous) {
            $userName = $userConfig.userUuid
        }
        else {
            $userName = $Env:USERNAME
        }

        $version = Get-ToolboxVersion
        $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"

        if ($ScriptError) {
            $errorStackTrace = $ScriptError.ScriptStackTrace
            $errorMessage = $ScriptError.FullyQualifiedErrorId
            $fileName = $appConfig.analytics.errorFileName
            $analytic = @{
                "timestamp"      = $timestamp;
                "userName"       = $userName;
                "toolboxVersion" = $version;
                "command"        = $Command;
                "arguments"      = [string]$Arguments;
                "errorMessage"   = $errorMessage;
                "stackTrace"     = $errorStackTrace;
            }
        }
        else {
            $fileName = $appConfig.analytics.usageFileName
            $analytic = @{
                "timestamp"      = $timestamp;
                "userName"       = $userName;
                "toolboxVersion" = $version;
                "command"        = $Command;
                "arguments"      = [string]$Arguments;
            }
        }
        
        $storagePath = $appConfig.analytics.storagePath
        $maxFileSizeInMb = $appConfig.analytics.maxFileSizeInMb

        Optimize-AnalyticsFile -StoragePath $storagePath -FileName $fileName -MaxFileSizeInMb $maxFileSizeInMb
        Add-Analytic -StoragePath $storagePath -FileName $fileName -Data $analytic
    }
    catch {
        Write-CliWarning "A configuration problem is preventing Toolbox from saving analytics."
    }
}

function Optimize-AnalyticsFile($StoragePath, $FileName, $MaxFileSizeInMb) {
    if (!$FileName -or !$StoragePath -or !$MaxFileSizeInMb -or !(Test-Path -Path $StoragePath)) {
        throw "Toolbox analytics configuration are not valid"
    }

    if (!(Test-Path -Path $StoragePath\$FileName.json)) {
        New-AnalyticsFile -StoragePath $storagePath -FileName $fileName
    }
    elseif (((Get-Item $StoragePath\$FileName.json).Length / 1MB) -gt $MaxFileSizeInMb) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        Rename-Item $StoragePath\$FileName.json $StoragePath\$FileName-$timestamp.json
        New-AnalyticsFile -StoragePath $storagePath -FileName $fileName
    }
}

function New-AnalyticsFile($StoragePath, $FileName) {
    if (!$FileName -or !$StoragePath -or !(Test-Path -Path $StoragePath)) {
        throw "Toolbox analytics configuration are not valid"
    }

    New-Item $StoragePath\$FileName.json -ItemType File -ErrorAction SilentlyContinue | Out-Null
    $initContent = @{
        "analytics" = @()
    }
    $content = Get-Content -Path $StoragePath\$FileName.json -ErrorAction Stop | ConvertFrom-JSON
    $content += $initContent
    $content | ConvertTo-JSON | Set-Content $StoragePath\$FileName.json
}

function Add-Analytic($StoragePath, $FileName, $Data) {
    if (!$FileName -or !$StoragePath -or !(Test-Path -Path $StoragePath)) {
        throw "Toolbox analytics configuration are not valid"
    }

    $content = Get-Content -Path $StoragePath\$FileName.json -ErrorAction Stop | ConvertFrom-JSON
    $content.analytics += $Data
    $content | ConvertTo-JSON | Set-Content $StoragePath\$FileName.json
}

function Get-CliCommand($Arguments) {
    if ($Arguments) {
        $argumentsArray = $Arguments.Split(" ")
        $command, $options = $argumentsArray
        return $command
    }

    return ""
}

function Get-FirtArgument($Arguments) {
    if ($Arguments) {
        $argumentsArray = $Arguments.Split(" ")
        $command, $options = $argumentsArray
        return $command
    }

    return ""
}

function Get-CliOptions($Arguments) {
    if ($Arguments) {
        $argumentsArray = $Arguments.Split(" ")
        $command, $options = $argumentsArray
        return $options
    }

    return @()
}

function Get-RemainingArguments($Arguments) {
    if ($Arguments) {
        $argumentsArray = $Arguments.Split(" ")
        $command, $options = $argumentsArray
        return $options
    }

    return @()
}

function Remove-Directory($Path) {
    if (!$Path -or !(Test-Path -Path $Path)) {
        return
    }

    $parentDirectoryItem = Get-Item -Path $Path
    Test-ItemLock $parentDirectoryItem

    $childItems = Get-ChildItem -Path $Path -Recurse -Force
    foreach ($childItem in $childItems) {
        Test-ItemLock $childItem
    }

    Get-ChildItem -Path $Path -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction Stop
    Remove-Item -Path $Path -Force -ErrorAction Stop | Out-Null
}

function Test-ItemLock($Item) {
    if (!$Item) {
        return
    }

    if ($Item.GetType().Name -eq "DirectoryInfo") {
        $parentFolder = $Item.Parent.FullName
    }
    else {
        $parentFolder = $Item.DirectoryName
    }
    
    $initialName = $Item.Name

    try {
        Rename-Item "$parentFolder\$initialName" "r$initialName" -ErrorAction Stop
        Rename-Item "$parentFolder\r$initialName" "$initialName" -ErrorAction Stop
    }
    catch {
        throw "The file '$parentFolder\$initialName' is locked by another process. Stop that process and try again."
    }
}

function New-Shortcut($TargetPath, $ShortcutName) {
    if (!$TargetPath -or !$ShortcutName -or !(Test-Path -Path $TargetPath)) {
        return
    }

    $appConfig = Get-AppConfig
    $shortcutsLocation = $appConfig.shortcutsLocation

    $fullShortcutsPath = $Env:USERPROFILE

    if ($shortcutsLocation) {
        $fullShortcutsPath += $shortcutsLocation
    }
    else {
        $fullShortcutsPath += "\Desktop"
    }

    if ($fullShortcutsPath -and (Test-Path -Path $fullShortcutsPath)) {
        $shortcutPath = "$fullShortcutsPath\$ShortcutName" + ".lnk"
        Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue

        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Save()
    }
}

function Remove-Shortcut($ShortcutName) {
    if (!$ShortcutName) {
        return
    }

    $appConfig = Get-AppConfig
    $shortcutsLocation = $appConfig.shortcutsLocation

    $fullShortcutsPath = $Env:USERPROFILE

    if ($shortcutsLocation) {
        $fullShortcutsPath += $shortcutsLocation
    }
    else {
        $fullShortcutsPath += "\Desktop"
    }

    if ($fullShortcutsPath -and (Test-Path -Path $fullShortcutsPath)) {
        $shortcutPath = "$fullShortcutsPath\$ShortcutName" + ".lnk"
        Remove-Item -Path $shortcutPath -Force -ErrorAction SilentlyContinue
    }
}

function Reset-ToolboxLocalRepository {
    $appConfig = Get-AppConfig
    $defaultBranch = $appConfig.toolbox.defaultBranch

    Start-Git @("-C", "$Env:TOOLBOX_HOME", "reset", "--hard", "origin/$defaultBranch", "--quiet")
}

function Start-Git($Params) {
    & "$Env:TOOLBOX_HOME\local\git\cmd\git.exe" $Params
}

function Unregister-ToolboxAutoUpdate {
    Write-Task "Unregistering Toolbox auto update triggers"

    Write-Host "Unregistering daily scheduled task"
    $taskName = "ToolboxAutoUpdateDaily"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Unregistering logon scheduled task"
    $taskName = "ToolboxAutoUpdateAtLogon"
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

    Remove-Item -Path "$Env:TOOLBOX_HOME\local\autoupdate.bat" -ErrorAction SilentlyContinue | Out-Null
}

function Register-ToolboxAutoUpdate {
    Write-Task "Registering Toolbox auto update triggers"

    New-Item -Path "$Env:TOOLBOX_HOME\local" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item -Path "$Env:TOOLBOX_HOME\local\autoupdate.bat" -ItemType File -Force -ErrorAction Stop | Out-Null
    Add-Content -Path "$Env:TOOLBOX_HOME\local\autoupdate.bat" -Value "@echo OFF"
    $scriptContent = "powershell "
    $scriptContent += '"'
    $scriptContent += "Start-Process -FilePath '%TOOLBOX_HOME%\bin\toolbox.bat' -ArgumentList 'update' -WindowStyle Hidden"
    $scriptContent += '"'
    Add-Content -Path "$Env:TOOLBOX_HOME\local\autoupdate.bat" -Value $scriptContent

    $argument = "/C call $Env:TOOLBOX_HOME\local\autoupdate.bat"
    $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument $argument
    
    Write-Host "Registering daily scheduled task"
    $taskName = "ToolboxAutoUpdateDaily"
    $trigger = New-ScheduledTaskTrigger -Daily -At "12pm"
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskPath "\Toolbox\AutoUpdate" -TaskName $taskName -Description "Start Toolbox auto update" -ErrorAction SilentlyContinue | Out-Null

    Write-Host "Registering logon scheduled task"
    $taskName = "ToolboxAutoUpdateAtLogon"
    $trigger = New-ScheduledTaskTrigger -AtLogon
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskPath "\Toolbox\AutoUpdate" -TaskName $taskName -Description "Start Toolbox auto update" -ErrorAction SilentlyContinue | Out-Null
}

function Get-MarkdownFileUrlFromRepository($GitRepository, $MarkdownType) {
    if ($GitRepository.Contains("github")) {
        $url = Get-MarkdownFileUrlFromGitHubRepository -GitRepository $GitRepository -MarkdownType $MarkdownType
        return $url
    }

    if ($GitRepository.Contains("gitlab")) {
        $url = Get-MarkdownFileUrlFromGitLabRepository -GitRepository $GitRepository -MarkdownType $MarkdownType
        return $url
    }

    if ($GitRepository.Contains("bitbucket")) {
        $url = Get-MarkdownFileUrlFromBitBucketRepository -GitRepository $GitRepository -MarkdownType $MarkdownType
        return $url
    }

    if ($GitRepository.Contains("dev.azure.com")) {
        $url = Get-MarkdownFileUrlFromAzureDevOpsRepository -GitRepository $GitRepository -MarkdownType $MarkdownType
        return $url
    }

    return "UNSUPPORTED"
}

function Get-MarkdownFileUrlFromGitHubRepository($GitRepository, $MarkdownType) {
    $markdownUrl = $GitRepository.Replace(".git", "/blob/main/$MarkdownType.md")
    return $markdownUrl
}

function Get-MarkdownFileUrlFromGitLabRepository($GitRepository, $MarkdownType) {
    $markdownUrl = $GitRepository.Replace(".git", "/-/blob/master/$MarkdownType.md")
    return $markdownUrl
}

function Get-MarkdownFileUrlFromBitBucketRepository($GitRepository, $MarkdownType) {
    $splitUrl = $GitRepository -split "/"
    $markdownUrl = $splitUrl[0] + "//" + $splitUrl[2] + "/projects/" + $splitUrl[4] + "/repos/" + $splitUrl[5].Replace(".git", "/browse/$MarkdownType.md")
    return $markdownUrl
}

function Get-MarkdownFileUrlFromAzureDevOpsRepository($GitRepository, $MarkdownType) {
    $splitUrl = $GitRepository -split "@"
    $markdownUrl = "https://" + $splitUrl[1]
    $markdownUrl += "?path=/$MarkdownType.md"
    return $markdownUrl
}