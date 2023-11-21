$rootPath = Resolve-Path -Path "$PSScriptRoot\..\.." -ErrorAction Stop
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $($rootPath.Path), "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $($rootPath.Path), "User")

."$Env:TOOLBOX_HOME\scripts\shared\common-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\proxy-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\git-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\analytics-module.ps1"

function Set-Toolbox {
    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host "                                Welcome!                                 " -ForegroundColor White
    Write-Host "                      Thank you for using Toolbox.                       " -ForegroundColor White
    Write-Host "   Before starting using it, few configurations need to be performed.    " -ForegroundColor White
    Write-Host "                 We will guide you through this process.                 " -ForegroundColor White
    Write-Host "#########################################################################`n" -ForegroundColor White
    
    Read-Host "Press ENTER to start configuration"

    if (Test-Path "$Env:TOOLBOX_HOME\pre-hook.ps1") {
        ."$Env:TOOLBOX_HOME\pre-hook.ps1"
    }

    Initialize-Toolbox
    Initialize-Proxy
    Initialize-Git
    Initialize-Analytics

    if (Test-Path "$Env:TOOLBOX_HOME\post-hook.ps1") {
        ."$Env:TOOLBOX_HOME\post-hook.ps1"
    }

    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host "                 Congratulations! Toolbox is configured.                 " -ForegroundColor White
    Write-Host "     You can now run 'toolbox' and 'git' commands from your terminal.    " -ForegroundColor White
    Write-Host "      For more information on how to use Toolbox, use: toolbox help      " -ForegroundColor White
    Write-Host "#########################################################################`n" -ForegroundColor White

    Read-Host "Press ENTER to finish configuration"
    
    Show-SignOutRequired

    exit
}

function Initialize-Toolbox {
    Set-ToolboxDefaultLocalDirectories
    Set-ToolboxEnvironmentVariables
    Set-ToolboxAutoUpdate
}

function Set-ToolboxDefaultLocalDirectories {
    Write-Task "Creating local directories"

    Write-Host "Creating \bin directory"
    New-Item -ItemType Directory -Path $Env:TOOLBOX_BIN -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Creating \apps directory"
    New-Item -ItemType Directory -Path $Env:TOOLBOX_APPS -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Creating \plans directory"
    New-Item -ItemType Directory -Path $Env:TOOLBOX_PLANS -ErrorAction SilentlyContinue | Out-Null
}

function Set-ToolboxEnvironmentVariables {
    Write-Task "Setting Toolbox environment variables"

    Edit-ExpandableEnvironmentMultipleValueData -EnvironmentValueName "PATH" -EnvironmentValueData "%TOOLBOX_HOME%\bin"
    Edit-ExpandableEnvironmentMultipleValueData -EnvironmentValueName "PATH" -EnvironmentValueData "%TOOLBOX_HOME%\local\bin"
}

function Set-ToolboxAutoUpdate {
    Unregister-ToolboxAutoUpdate

    $toolboxAutoUpdateConfig = Get-ToolboxAutoUpdateConfig

    if (($null -ne $toolboxAutoUpdateConfig) -and $toolboxAutoUpdateConfig) {
        Register-ToolboxAutoUpdate
    }
}

Set-Toolbox
