$toolboxRootResolved = Resolve-Path -Path "$PSScriptRoot\..\.." -ErrorAction Stop
$toolboxRootPath = $toolboxRootResolved.Path
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $toolboxRootPath, "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_APPS", "$toolboxRootPath\local\apps", "Process")

."$Env:TOOLBOX_HOME\scripts\apis\apis-module.ps1"

$appConfig = Get-AppConfig
foreach ($environmentVariableName in $appConfig.environmentVariables.PSObject.Properties.Name) {
	if (($environmentVariableName -ne "APPS") -and ($environmentVariableName -ne "HOME")) {
		$environmentVariableValue = $appConfig.environmentVariables.$environmentVariableName
		[System.Environment]::SetEnvironmentVariable("TOOLBOX_$environmentVariableName", $environmentVariableValue, "Process")
	}
}

try {
	Reset-ToolboxLocalRepository

	$Command = Get-CliCommand $args
	$Options = Get-CliOptions $args

	Send-Analytics -Command $Command -Options $Options
	
	switch -CaseSensitive ($Command) {
		"" { ."$Env:TOOLBOX_HOME\scripts\commands\help.ps1" }
		"privacy" { ."$Env:TOOLBOX_HOME\scripts\commands\privacy.ps1" $Options }
		"docs" { ."$Env:TOOLBOX_HOME\scripts\commands\docs.ps1" }
		"help" { ."$Env:TOOLBOX_HOME\scripts\commands\help.ps1" }
		"install" { ."$Env:TOOLBOX_HOME\scripts\commands\install.ps1" $Options }
		"list" { ."$Env:TOOLBOX_HOME\scripts\commands\list.ps1" }
		"proxy" { ."$Env:TOOLBOX_HOME\scripts\commands\proxy.ps1" $Options }
		"uninstall" { ."$Env:TOOLBOX_HOME\scripts\commands\uninstall.ps1" $Options }
		"update" { ."$Env:TOOLBOX_HOME\scripts\commands\update.ps1" }
		"version" { ."$Env:TOOLBOX_HOME\scripts\commands\version.ps1" }
		default {
			." $Env:TOOLBOX_HOME\scripts\commands\help.ps1" $Command
		}
	}
}
catch {
	Send-Analytics -Command $Command -Options $Options -ScriptError $_

	Write-CliError $_
	Write-CliError $_.ScriptStackTrace
}
