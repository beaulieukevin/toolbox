function Initialize-Git {
    Expand-Git
    Set-GitPath
    Set-GitSystemConfig
    Set-GitGlobalConfig
    Set-ToolboxRepository
}

function Expand-Git {
    $appConfig = Get-AppConfig
    $gitVersion = $appConfig.git.version
    
    Write-Task "Expanding Git $gitVersion"

    Write-Host "Deleting Git directory in Toolbox"
    Remove-Directory -Path "$Env:TOOLBOX_HOME\local\git"
    Write-Host "\local\git directory has been deleted"

    Write-Host "Unzipping Git"
    $zipFilePath = "$Env:TOOLBOX_HOME\libs\MinGit-$gitVersion-64-bit.zip"
    $destinationPath = "$Env:TOOLBOX_HOME\local\git"
    Expand-Archive $zipFilePath -DestinationPath $destinationPath
    Write-Host "Git $gitVersion has been unzipped in \local\git directory"
}

function Set-GitPath {
    Write-Task "Setting Git environment variable"

    Write-Host "Updating PATH environment variable"
    $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = "";

    if ($path) {
        $pathValues = $path.Split(";")
    }

    foreach ($pathValue in $pathValues) {
        if ($pathValue -and (Test-Path $pathValue) -and !(Test-Path "$pathValue\git.exe")) {
            $newPath += $pathValue + ";"
        }
    }

    $toolboxPathResolved = Resolve-Path -Path "$Env:TOOLBOX_HOME\local\git\cmd" -ErrorAction Stop
    $newPath += $toolboxPathResolved.Path + ";"

    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Process")
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "PATH environment variable has been updated"
}

function Set-GitSystemConfig {
    param([switch]$OnlyConfigFile)

    Write-Task "Updating Git system configuration file"

    if (!$OnlyConfigFile.IsPresent) {
        $caCertsPathResolved = Resolve-Path -Path "$Env:TOOLBOX_HOME\local\git\mingw64\etc\ssl\certs\ca-bundle.crt" -ErrorAction Stop
        Write-Host "Setting 'http.sslCAInfo' key to" $caCertsPathResolved.Path
        Start-Git @("config", "--system", "http.sslCAInfo", $caCertsPathResolved.Path)
    }

    $appConfig = Get-AppConfig
    
    foreach ($setting in $appConfig.git.systemConfig.PSObject.Properties.Name) {
        $settings = $appConfig.git.systemConfig
        $settingValue = $settings.$setting
        Write-Host "Setting '$setting' key to" $settingValue
        Start-Git @("config", "--system", $setting, $settingValue)
    }
}

function Set-GitGlobalConfig {
    param([switch]$OnlyConfigFile)

    Write-Task "Updating Git global configuration file"

    if (!$OnlyConfigFile.IsPresent) {
        $userInput = Read-Host "Enter your name required for Git (default: $Env:USERNAME)"
        if ($userInput) {
            $gitName = $userInput
        }
        else {
            $gitName = $Env:USERNAME
        }
        Write-Host "Setting 'user.name' key to" $gitName
        Start-Git @("config", "--global", "user.name", $gitName)

        $appConfig = Get-AppConfig
        $emailDomain = $appConfig.organization.emailDomain
        $userInput = Read-Host "Enter your email required for Git (default: $Env:USERNAME@$emailDomain)"
        if ($userInput) {
            $gitEmail = $userInput
        }
        else {
            $gitEmail = "$Env:USERNAME@$emailDomain"
        }
        Write-Host "Setting 'user.email' key to" $gitEmail
        Start-Git @("config", "--global", "user.email", $gitEmail)
    }

    $appConfig = Get-AppConfig
    
    foreach ($setting in $appConfig.git.globalConfig.PSObject.Properties.Name) {
        $settings = $appConfig.git.globalConfig
        $settingValue = $settings.$setting
        Write-Host "Setting '$setting' key to" $settingValue
        Start-Git @("config", "--global", $setting, $settingValue)
    }
}

function Set-ToolboxRepository {
    $appConfig = Get-AppConfig
    $gitRepository = $appConfig.toolbox.gitRepository
    $defaultBranch = $appConfig.toolbox.defaultBranch
    $organizationName = $appConfig.organization.name

    Write-Task "Syncing Toolbox with $organizationName's Source Control Management (SCM)"

    Write-Host "Initializing local repository"
    Start-Git @("-C", "$Env:TOOLBOX_HOME", "init", "--quiet")

    Write-Host "Updating remote repository with $gitRepository"
    Start-Git @("-C", "$Env:TOOLBOX_HOME", "remote", "add", "origin", $gitRepository)
 
    Write-Host "Fetching remote repository. It might take few minutes."
    Write-CliWarning "A Git logon screen might appear. If it is the case, please authenticate using your credentials."

    Start-Git @("-C", "$Env:TOOLBOX_HOME", "fetch", "origin", "--quiet")
    Start-Git @("-C", "$Env:TOOLBOX_HOME", "reset", "--hard", "origin/$defaultBranch", "--quiet")
    Start-Git @("-C", "$Env:TOOLBOX_HOME", "branch", "--set-upstream-to=origin/$defaultBranch", "main", "--quiet")
}
