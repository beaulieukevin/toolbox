function Get-CompanyProxyConfig {
    $companyConfig = Get-CompanyConfig
    return $companyConfig.proxy
}

function Get-CompanyProxyVersion {
    $companyProxyConfig = Get-CompanyProxyConfig
    return $companyProxyConfig.version
}

function Get-CompanyProxyLocalHost {
    $companyProxyConfig = Get-CompanyProxyConfig
    return $companyProxyConfig.config.localHost
}

function Get-CompanyProxyLocalPort {
    $companyProxyConfig = Get-CompanyProxyConfig
    return $companyProxyConfig.config.localPort
}

function Get-CompanyProxyNoProxy {
    $companyProxyConfig = Get-CompanyProxyConfig
    return $companyProxyConfig.config.noProxy
}

function Initialize-Proxy {
    $proxy = Get-CompanyProxyConfig

    if (!$proxy) {
        return
    }

    $address = [System.Net.WebProxy]::GetDefaultProxy().Address

    if (!$address) {
        return
    }

    Stop-Px
    Expand-Px
    Set-PxConfig
    Start-Px
    Set-PxAutoRun
}

function Stop-Px {
    Write-Task "Terminating Px proxy"

    Write-Host "Ending all processes"
    Stop-Process -Name "px" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing HTTP_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "", "User")

    Write-Host "Removing HTTPS_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "", "User")
}

function Expand-Px {
    $version = Get-CompanyProxyVersion

    Write-Task "Expanding Px $version"
    Remove-Directory -Path "$Env:TOOLBOX_HOME\local\px"
    
    Write-Host "Unzipping Px"
    $zipFilePath = "$Env:TOOLBOX_HOME\libs\px-v$version.zip"
    $destinationPath = "$Env:TOOLBOX_HOME\local"
    Expand-Archive $zipFilePath -DestinationPath $destinationPath
    Rename-Item "$Env:TOOLBOX_HOME\local\px-v$version" "px"
}

function Set-PxConfig {
    Write-Task "Updating Px configuration file"

    $localHost = Get-CompanyProxyLocalHost
    $localPort = Get-CompanyProxyLocalPort
    $noProxy = Get-CompanyProxyNoProxy

    Write-Host "Fetching company's proxy settings"

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

function Get-PxProcesses {
    $processes = Get-Process "px" -ErrorAction SilentlyContinue
    return $processes.Count
}

function Start-Px {
    Write-Task "Starting Px proxy"

    $localHost = Get-CompanyProxyLocalHost
    $localPort = Get-CompanyProxyLocalPort

    Write-Host "Updating HTTP_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://${localHost}:$localPort", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://${localHost}:$localPort", "User")

    Write-Host "Updating HTTPS_PROXY environment variable"
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://${localHost}:$localPort", "Process")
    [System.Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://${localHost}:$localPort", "User")

    Write-Host "Waiting for Px to start..."
    & "$Env:TOOLBOX_HOME\local\px\px.exe"

    $numberOfProcesses = Get-PxProcesses

    while ($numberOfProcesses -lt 2) {
        Start-Sleep 1
        $numberOfProcesses = Get-PxProcesses
    }
}

function Set-PxAutoRun {
    Write-Task "Setting Px to start automatically at logon"

    Write-Host "Updating Windows registry"
    $proxyPathResolved = Resolve-Path -Path "$Env:TOOLBOX_HOME\local\px\px.exe" -ErrorAction Stop
    $regKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', $true)
    $regKey.SetValue("Px", $proxyPathResolved.Path, "String")
}

function Start-Proxy {
    Start-Px
}

function Stop-Proxy {
    Stop-Px
}

function Get-ProxyProcesses {
    return Get-PxProcesses
}
