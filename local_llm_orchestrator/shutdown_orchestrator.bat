@echo off
setlocal enabledelayedexpansion
set "PROJECT_DIR=%~dp0"
set "TMP_DIR=%PROJECT_DIR%tmp"
set "LOG_DIR=%PROJECT_DIR%log"
set "SHUTDOWN_LOG=%LOG_DIR%\orchestrator_stop.log"

:: 3. INITIALIZE LOG FILE
echo ======================================================================== > "%SHUTDOWN_LOG%"
echo SHUTDOWN SEQUENCE INITIATED: %DATE% %TIME% >> "%SHUTDOWN_LOG%"
echo ======================================================================== >> "%SHUTDOWN_LOG%"

:: 4. SCAN AND DIAGNOSE
if exist "%TMP_DIR%\*.pid" (
    for %%F in ("%TMP_DIR%\*.pid") do (
        if not "%%~nxF"=="orchestrator.pid" (
            set /p TARGET_PID=<"%%F"
            
            :: Check if process exists
            tasklist /FI "PID eq !TARGET_PID!" 2>NUL | findstr /I "!TARGET_PID!" >NUL
            
            :: Linear logic: If process exists, perform diagnostic and kill
            if !errorlevel! equ 0 (
                echo Diagnosing and terminating PID !TARGET_PID!...
                echo [DIAGNOSTIC] PID !TARGET_PID! found for %%~nxF >> "%SHUTDOWN_LOG%"
                tasklist /FI "PID eq !TARGET_PID!" /FO TABLE >> "%SHUTDOWN_LOG%"
                taskkill /PID !TARGET_PID! /T /F >> "%SHUTDOWN_LOG%" 2>&1
                echo [RESULT] Tree terminated. >> "%SHUTDOWN_LOG%"
            )
            del "%%F" 2>NUL
        )
    )
)

:: 5. CLEANUP
if exist "%TMP_DIR%\orchestrator.pid" del "%TMP_DIR%\orchestrator.pid" 2>NUL
echo Teardown complete.
pause