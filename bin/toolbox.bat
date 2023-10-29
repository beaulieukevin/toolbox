@echo OFF

set current_location=%~dp0
set command=%*

powershell -NoProfile -ExecutionPolicy bypass -File "%current_location%..\scripts\core\toolbox.ps1" %command%
