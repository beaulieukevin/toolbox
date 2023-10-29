function Initialize-Proxy {
    $appConfig = Get-AppConfig
    $organizationName = $appConfig.organization.name
    $proxy = $appConfig.proxy

    if (!$proxy) {
        return
    }

    $address = [System.Net.WebProxy]::GetDefaultProxy().Address

    if (!$address) {
        return
    }

    Write-Task "We have detected that $organizationName is running behind the following proxy:"
    Write-Host $address.OriginalString

    Start-Px
}

function Expand-Px {
    $appConfig = Get-AppConfig
    $version = $appConfig.proxy.version

    Write-Task "Expanding Px $version"

    Write-Host "Deleting Px directory in Toolbox"
    Remove-Directory -Path "$Env:TOOLBOX_HOME\local\px"
    Write-Host "\local\px directory has been deleted"
    
    Write-Host "Unzipping Px"
    $zipFilePath = "$Env:TOOLBOX_HOME\libs\px-v$version.zip"
    $destinationPath = "$Env:TOOLBOX_HOME\local"
    Expand-Archive $zipFilePath -DestinationPath $destinationPath
    Rename-Item "$Env:TOOLBOX_HOME\local\px-v$version" "px"
    Write-Host "Px $version has been unzipped in \local\px directory"
}

function Update-Px {
    Write-Task "A new version of Px proxy is available, updating it to the latest version"

    Stop-Px
    Expand-Px
    Set-Px
    Set-PxAutoStart
    
    Set-LocalProxyEnvironmentVariables
    
    Write-Task "Starting Px proxy"

    Write-Host "Waiting for Px to start"
    & "$Env:TOOLBOX_HOME\local\px\px.exe"

    $numberOfProcesses = Get-ProxyProcesses

    while ($numberOfProcesses -lt 2) {
        Start-Sleep 1
        $numberOfProcesses = Get-ProxyProcesses
    }
}

function Set-PxConfig {
    Stop-Px
    Set-Px

    Set-LocalProxyEnvironmentVariables

    Write-Task "Starting Px proxy"

    Write-Host "Waiting for Px to start"
    & "$Env:TOOLBOX_HOME\local\px\px.exe"

    $numberOfProcesses = Get-ProxyProcesses

    while ($numberOfProcesses -lt 2) {
        Start-Sleep 1
        $numberOfProcesses = Get-ProxyProcesses
    }
}

function Start-Px {
    Stop-Px
        
    if (!(Test-Path "$Env:TOOLBOX_HOME\local\px\px.exe")) {
        Expand-Px
        Set-Px
        Set-PxAutoStart
    }
    
    Set-LocalProxyEnvironmentVariables
    
    Write-Task "Starting Px proxy"

    Write-Host "Waiting for Px to start"
    & "$Env:TOOLBOX_HOME\local\px\px.exe"

    $numberOfProcesses = Get-ProxyProcesses

    while ($numberOfProcesses -lt 2) {
        Start-Sleep 1
        $numberOfProcesses = Get-ProxyProcesses
    }
}

function Set-Px {
    Write-Task "Updating Px configuration file"

    $appConfig = Get-AppConfig
    $localHost = $appConfig.proxy.config.localHost
    $localPort = $appConfig.proxy.config.localPort
    $noProxy = $appConfig.proxy.config.noProxy
    $organizationName = $appConfig.organization.name

    Write-Host "Fetching $organizationName's proxy settings"

    $address = [System.Net.WebProxy]::GetDefaultProxy().Address
    if ($address) {
        $organizationProxy = $address.Authority
        
        Write-Host "Saving Px configuration file"

        $startParams = @{
            FilePath     = "$Env:TOOLBOX_HOME\local\px\px.exe"
            ArgumentList = "--server=$organizationProxy", "--listen=$localHost", "--port=$localPort", "--noproxy=$noProxy", "--save"
            Wait         = $true
            PassThru     = $true
        }

        Start-Process @startParams | Out-Null
    }
}

function Set-PxAutoStart {
    Write-Task "Setting Px to start automatically at logon"

    Write-Host "Updating Windows registry to launch Px at startup"
    $proxyPathResolved = Resolve-Path -Path "$Env:TOOLBOX_HOME\local\px\px.exe" -ErrorAction Stop
    $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', $true)
    $regKey.SetValue("Px", $proxyPathResolved.Path, "String")
}

function Get-PxProcesses {
    $processes = Get-Process "px" -ErrorAction SilentlyContinue
    return $processes.Count
}

function Stop-Px {
    Write-Task "Terminating Px local proxy instances"

    Write-Host "Ending all Px processes"
    Stop-Process -Name "px" -Force -ErrorAction SilentlyContinue

    Remove-LocalProxyEnvironmentVariables
}

function Remove-Px {
    Stop-Px

    Remove-Directory -Path "$Env:TOOLBOX_HOME\local\px"
    
    $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', $true)
    $regKey.SetValue("Px", "", "String")
}

function Set-LocalProxyEnvironmentVariables {
    Write-Task "Setting local proxy environment variables"

    $appConfig = Get-AppConfig
    $localHost = $appConfig.proxy.config.localHost
    $localPort = $appConfig.proxy.config.localPort

    Write-Host "Updating HTTP_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://${localHost}:$localPort", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://${localHost}:$localPort", "User")
    Write-Host "HTTP_PROXY environment variable has been updated"

    Write-Host "Updating HTTPS_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://${localHost}:$localPort", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://${localHost}:$localPort", "User")
    Write-Host "HTTPS_PROXY environment variable has been updated"
}

function Remove-LocalProxyEnvironmentVariables {
    Write-Task "Setting local proxy environment variables"

    Write-Host "Removing HTTP_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "", "User")
    Write-Host "HTTP_PROXY environment variable has been removed"

    Write-Host "Removing HTTPS_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", "User")
    Write-Host "HTTPS_PROXY environment variable has been removed"
}

function Start-Proxy {
    Start-Px
}

function Update-Proxy {
    $appConfig = Get-AppConfig
    $proxy = $appConfig.proxy

    if ($proxy) {
        Update-Px
    }
    else {
        Remove-Px
    }
}

function Set-ProxyConfig {
    $appConfig = Get-AppConfig
    $proxy = $appConfig.proxy

    if ($proxy) {
        Set-PxConfig
    }
}

function Get-ProxyProcesses {
    return Get-PxProcesses
}

function Stop-Proxy {
    Stop-Px
}
