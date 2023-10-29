$toolboxRootResolved = Resolve-Path -Path "$PSScriptRoot\..\.." -ErrorAction Stop
$toolboxRootPath = $toolboxRootResolved.Path
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $toolboxRootPath, "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $toolboxRootPath, "User")

."$Env:TOOLBOX_HOME\scripts\apis\apis-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\analytics-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\git-module.ps1"
."$Env:TOOLBOX_HOME\scripts\core\proxy-module.ps1"

function Set-Toolbox {
    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host "                                Welcome!                                 " -ForegroundColor White
    Write-Host "        Thank you for using Toolbox Command Line Interface (CLI).        " -ForegroundColor White
    Write-Host " Before starting using the CLI, few configurations need to be performed. " -ForegroundColor White
    Write-Host "                 We will guide you through this process.                 " -ForegroundColor White
    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host ""
    Read-Host "Press ENTER to start configuration"

    Initialize-Toolbox
    Initialize-Proxy
    Initialize-Git
    Initialize-Analytics

    Write-Host ""
    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host "               Congratulations! Toolbox CLI is configured.               " -ForegroundColor White
    Write-Host "     You can now run 'toolbox' and 'git' commands from your terminal.    " -ForegroundColor White
    Write-Host "      For more information on how to use Toolbox, use: toolbox help      " -ForegroundColor White
    Write-Host "#########################################################################" -ForegroundColor White
    Write-Host ""

    Read-Host "Press ENTER to exit configuration"

    exit 0
}

function Initialize-Toolbox {
    Start-InitDirectory
    Start-InitToolboxEnvironmentVariables
    Start-AutoUpdateSetup
}

function Start-InitDirectory {
    Write-Task "Creating local directories"

    Write-Host "Creating \local\bin directory"
    New-Item -ItemType Directory -Path "$Env:TOOLBOX_HOME\local\bin" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "\local\bin directory created"
    Write-Host "Creating \local\apps directory"
    New-Item -ItemType Directory -Path "$Env:TOOLBOX_HOME\local\apps" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "\local\apps folder created"
    Write-Host "Creating \local\plans directory"
    New-Item -ItemType Directory -Path "$Env:TOOLBOX_HOME\local\plans" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "\local\plans folder created"
}

function Start-InitToolboxEnvironmentVariables {
    Write-Task "Setting Toolbox environment variables"

    Write-Host "Updating PATH environment variable"
    $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = "";
    
    if ($path) {
        $pathValues = $path.Split(";")
    }

    foreach ($pathValue in $pathValues) {
        if (Test-Path "$pathValue\toolbox.bat") {
            $pathToDelete = $pathValue
            $localPathToDelete = Resolve-Path -Path "$pathValue\..\local\bin" -ErrorAction Stop
        }
    }

    foreach ($pathValue in $pathValues) {
        if ($pathValue -and (Test-Path $pathValue) -and ($pathValue -ne $pathToDelete) -and ($pathValue -ne $localPathToDelete)) {
            $newPath += $pathValue + ";"
        }
    }

    $newPath += "$Env:TOOLBOX_HOME\bin;"
    $newPath += "$Env:TOOLBOX_HOME\local\bin;"

    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Process")
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "PATH environment variable has been updated"

    Write-Host "Updating TOOLBOX_APPS environment variable"
    [System.Environment]::SetEnvironmentVariable("TOOLBOX_APPS", "$toolboxRootPath\local\apps", "Process")
    [System.Environment]::SetEnvironmentVariable("TOOLBOX_APPS", "$toolboxRootPath\local\apps", "User")
    Write-Host "TOOLBOX_APPS environment variable has been updated"

    Write-Host "Updating Toolbox CLI environment variables"
    $toolboxVariables = Get-ChildItem Env:TOOLBOX_*
    foreach ($toolboxVariable in $toolboxVariables) {
        if (($toolboxVariable.Name -ne "TOOLBOX_APPS") -and ($toolboxVariable.Name -ne "TOOLBOX_HOME")) {
            [System.Environment]::SetEnvironmentVariable($toolboxVariable.Name, "", "Process")
            [System.Environment]::SetEnvironmentVariable($toolboxVariable.Name, "", "User")
        }
    }

    $appConfig = Get-AppConfig
    foreach ($environmentVariableName in $appConfig.environmentVariables.PSObject.Properties.Name) {
        if (($environmentVariableName -ne "APPS") -and ($environmentVariableName -ne "HOME")) {
            $environmentVariableValue = $appConfig.environmentVariables.$environmentVariableName
            [System.Environment]::SetEnvironmentVariable("TOOLBOX_$environmentVariableName", $environmentVariableValue, "Process")
            [System.Environment]::SetEnvironmentVariable("TOOLBOX_$environmentVariableName", $environmentVariableValue, "User")
        }
        else {
            Write-Host "Cannot update protected TOOLBOX_APPS or TOOLBOX_HOME environment variables"
        }
        
        Write-Host "Toolbox CLI environment variables have been updated"
    }
}

function Start-AutoUpdateSetup {
    Unregister-ToolboxCLIAutoUpdate

    $appConfig = Get-AppConfig
    $toolboxAutoUpdate = $appConfig.toolbox.autoUpdate

    if (($null -ne $toolboxAutoUpdate) -and $toolboxAutoUpdate) {
        Write-Task "Scheduling Toolbox CLI auto update"
        Register-ToolboxCLIAutoUpdate
    }
}

Set-Toolbox
