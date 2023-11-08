$rootPath = Resolve-Path -Path "$PSScriptRoot\..\.." -ErrorAction Stop
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $($rootPath.Path), "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $($rootPath.Path), "User")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_APPS", "$($rootPath.Path)\local\apps", "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_PLANS", "$($rootPath.Path)\local\plans", "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_BIN", "$($rootPath.Path)\local\bin", "Process")

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

    Initialize-Toolbox
    Initialize-Proxy
    Initialize-Git
    Initialize-Analytics

    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host "                 Congratulations! Toolbox is configured.                 " -ForegroundColor White
    Write-Host "     You can now run 'toolbox' and 'git' commands from your terminal.    " -ForegroundColor White
    Write-Host "      For more information on how to use Toolbox, use: toolbox help      " -ForegroundColor White
    Write-Host "#########################################################################`n" -ForegroundColor White

    Read-Host "Press ENTER to exit configuration"

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

    Write-Host "Preparing PATH environment variable"
    $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = "";
    
    if ($path) {
        $pathValues = $path.Split(";")
    }

    foreach ($pathValue in $pathValues) {
        if (Test-Path "$pathValue\toolbox.bat") {
            $toolboxPathToDelete = $pathValue
            $binPathToDelete = Resolve-Path -Path "$pathValue\..\local\bin" -ErrorAction SilentlyContinue
        }
    }

    foreach ($pathValue in $pathValues) {
        if ($pathValue -and (Test-Path $pathValue) -and ($pathValue -ne $toolboxPathToDelete) -and ($pathValue -ne $binPathToDelete)) {
            $newPath += $pathValue + ";"
        }
    }

    Write-Host "Adding Toolbox \bin folders to PATH environment variable"
    $newPath += "$Env:TOOLBOX_HOME\bin;"
    $newPath += "$Env:TOOLBOX_BIN;"

    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Process")
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
}

function Set-ToolboxAutoUpdate {
    Unregister-ToolboxAutoUpdate

    $toolboxAutoUpdateConfig = Get-ToolboxAutoUpdateConfig

    if (($null -ne $toolboxAutoUpdateConfig) -and $toolboxAutoUpdateConfig) {
        Register-ToolboxAutoUpdate
    }
}

Set-Toolbox
