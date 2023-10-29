@echo OFF

set current_location=%~dp0

powershell "Get-ChildItem -Path '%current_location%scripts\*.ps1' -Recurse | Unblock-File"
powershell -NoProfile -ExecutionPolicy bypass -File "%current_location%scripts\core\setup.ps1"
