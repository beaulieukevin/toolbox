$rootPath = Resolve-Path -Path "$PSScriptRoot\..\.." -ErrorAction Stop
[System.Environment]::SetEnvironmentVariable("TOOLBOX_HOME", $($rootPath.Path), "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_APPS", "$($rootPath.Path)\local\apps", "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_PLANS", "$($rootPath.Path)\local\plans", "Process")
[System.Environment]::SetEnvironmentVariable("TOOLBOX_BIN", "$($rootPath.Path)\local\bin", "Process")

."$Env:TOOLBOX_HOME\scripts\shared\common-module.ps1"

$variables = Get-CompanyEnvironmentVariables
$restrictedVariables = @("HOME", "APPS", "PLANS", "BIN")
foreach ($variableName in $variables.PSObject.Properties.Name) {
	if ($variableName -notin $restrictedVariables) {
		$variableValue = $variables.$variableName
		[System.Environment]::SetEnvironmentVariable("TOOLBOX_$variableName", $variableValue, "Process")
	}
}

try {
	Reset-ToolboxLocalRepository

	$command = Get-FirtArgument -Arguments $args
	$arguments = Get-RemainingArguments -Arguments $args

	Send-ToolboxAnalytics -Command $command -Arguments $arguments
	
	switch -CaseSensitive ($command) {
		"" { ."$Env:TOOLBOX_HOME\scripts\commands\help.ps1" }
		"docs" { ."$Env:TOOLBOX_HOME\scripts\commands\docs.ps1" }
		"help" { ."$Env:TOOLBOX_HOME\scripts\commands\help.ps1" }
		"install" { ."$Env:TOOLBOX_HOME\scripts\commands\install.ps1" $arguments }
		"list" { ."$Env:TOOLBOX_HOME\scripts\commands\list.ps1" }
		"privacy" { ."$Env:TOOLBOX_HOME\scripts\commands\privacy.ps1" $arguments }
		"proxy" { ."$Env:TOOLBOX_HOME\scripts\commands\proxy.ps1" $arguments }
		"uninstall" { ."$Env:TOOLBOX_HOME\scripts\commands\uninstall.ps1" $arguments }
		"update" { ."$Env:TOOLBOX_HOME\scripts\commands\update.ps1" }
		"version" { ."$Env:TOOLBOX_HOME\scripts\commands\version.ps1" }
		default {
			Write-Host "'$command' is not a valid Toolbox command.`n" -ForegroundColor Yellow
			." $Env:TOOLBOX_HOME\scripts\commands\help.ps1"
		}
	}
}
catch {
	Send-ToolboxAnalytics -Command $command -Arguments $arguments -ScriptError $_
	Write-Host $_ -ForegroundColor Red
}
