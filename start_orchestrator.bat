@echo off
if not exist "%~dp0log" mkdir "%~dp0log"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-Stack.ps1" > "%~dp0log\orchestrator_start.log" 2>&1