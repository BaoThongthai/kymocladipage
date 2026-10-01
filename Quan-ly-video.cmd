@echo off
cd /d "%~dp0"
powershell -STA -NoProfile -ExecutionPolicy Bypass -File "tools\video-manager.ps1"
if errorlevel 1 pause
