param(
    [Parameter(Position = 0)]
    [string]$Command
)

if ($Command) {
    Write-Host "'$Command' is not a valid Toolbox command."
    Write-Host ""
}

Write-Help
