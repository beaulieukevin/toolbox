function Get-GitVersion {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.git.version
}

function Get-GitSystemConfig {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.git.systemConfig
}

function Get-GitGlobalConfig {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.git.globalConfig
}

function Get-ToolboxGitRepository {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.toolbox.gitRepository
}

function Get-ToolboxGitDefaultBranch {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.toolbox.defaultBranch
}

function Initialize-Git {
    Expand-Git
    Set-GitPath
    Set-GitSystemConfig
    Set-GitGlobalConfig
    Initialize-ToolboxRepository
}

function Expand-Git {
    $gitVersion = Get-GitVersion
    
    Write-Task "Expanding Git $gitVersion"
    Remove-Directory -Path "$Env:TOOLBOX_HOME\local\git"

    Write-Host "Unzipping Git"
    $zipFilePath = "$Env:TOOLBOX_HOME\libs\MinGit-$gitVersion-64-bit.zip"
    $destinationPath = "$Env:TOOLBOX_HOME\local\git"
    Expand-Archive $zipFilePath -DestinationPath $destinationPath
}

function Set-GitPath {
    Write-Task "Setting Git environment variable"

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

    $gitPath = Resolve-Path -Path "$Env:TOOLBOX_HOME\local\git\cmd" -ErrorAction Stop
    $newPath += $gitPath.Path + ";"

    Write-Host "Updating PATH environment variable"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Process")
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
}

function Set-GitSystemConfig {
    Write-Task "Updating Git system configuration file"

    $caBundlePath = Resolve-Path -Path "$Env:TOOLBOX_HOME\local\git\mingw64\etc\ssl\certs\ca-bundle.crt" -ErrorAction Stop
    Write-Host "Setting 'http.sslCAInfo' key to" $caBundlePath.Path
    Start-Git @("config", "--system", "http.sslCAInfo", $caBundlePath.Path)
    
    $gitSystemConfig = Get-GitSystemConfig
    
    foreach ($settingName in $gitSystemConfig.PSObject.Properties.Name) {
        $settingValue = $gitSystemConfig.$settingName
        Write-Host "Setting '$settingName' key to" $settingValue
        Start-Git @("config", "--system", $settingName, $settingValue)
    }
}

function Set-GitGlobalConfig {
    param(
        [switch]$NoPrompt
    )

    Write-Task "Updating Git global configuration file"

    if (!$NoPrompt) {
        $userInput = Read-Host "Enter your name required for Git (default: $Env:USERNAME)"
        if ($userInput) {
            $gitName = $userInput
        }
        else {
            $gitName = $Env:USERNAME
        }
        Write-Host "Setting 'user.name' key to" $gitName
        Start-Git @("config", "--global", "user.name", $gitName)

        $emailDomain = Get-CompanyEmailDomain
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

    $gitGlobalConfig = Get-GitGlobalConfig
    
    foreach ($settingName in $gitGlobalConfig.PSObject.Properties.Name) {
        $settingValue = $gitGlobalConfig.$settingName
        Write-Host "Setting '$settingName' key to" $settingValue
        Start-Git @("config", "--global", $settingName, $settingValue)
    }
}

function Initialize-ToolboxRepository {
    $gitRepository = Get-ToolboxGitRepository
    $defaultBranch = Get-ToolboxGitDefaultBranch

    Write-Task "Syncing Toolbox with defined Source Control Management (SCM)"

    Write-Host "Initializing local repository"
    Start-Git @("-C", $Env:TOOLBOX_HOME, "init", "--quiet")

    Write-Host "Updating remote repository with $gitRepository"
    Start-Git @("-C", $Env:TOOLBOX_HOME, "remote", "add", "origin", $gitRepository)
 
    Write-Host "Fetching remote repository. It might take few minutes."
    Write-CliWarning "A Git logon screen might appear. If it is the case, please authenticate using your credentials."

    Start-Git @("-C", $Env:TOOLBOX_HOME, "fetch", "origin", "--quiet")
    Start-Git @("-C", $Env:TOOLBOX_HOME, "reset", "--hard", "origin/$defaultBranch", "--quiet")
    Start-Git @("-C", $Env:TOOLBOX_HOME, "branch", "--set-upstream-to=origin/$defaultBranch", "main", "--quiet")
}
