@echo off
setlocal enabledelayedexpansion

:: 1. SET EXPLICIT WORKSPACE PROJECT PATH CONTEXT
set "PROJECT_DIR=%~dp0"
set "TMP_DIR=%PROJECT_DIR%tmp"
set "LOG_DIR=%PROJECT_DIR%log"
set "ENV_DIR=%PROJECT_DIR%env"
set "CONFIG_DIR=%PROJECT_DIR%config"
set "SPEC_DIR=%PROJECT_DIR%specification"

:: 2. AUTO-GENERATE REQUIRED MISSING ISOLATED DOMAINS
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%ENV_DIR%" mkdir "%ENV_DIR%"
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
if not exist "%SPEC_DIR%" mkdir "%SPEC_DIR%"

:: 3. LOG THE PARENT ORCHESTRATOR PID TO PREVENT SELF-LOCKING
powershell -NoProfile -Command "[String]$parent = (Get-CimInstance Win32_Process -Filter \"ProcessId = $PID\").ParentProcessId; $parent | Out-File -FilePath '%TMP_DIR%\orchestrator.pid' -Encoding ascii"

:: 4. DYNAMIC AMBIENT CONCURRENCY CHECK FROM TMP FILE TRACKING
set STACK_RUNNING=0

if exist "%TMP_DIR%\*.pid" (
    for %%F in ("%TMP_DIR%\*.pid") do (
        if not "%%~nxF"=="orchestrator.pid" (
            set /p TARGET_PID=<"%%F"
            tasklist /FI "PID eq !TARGET_PID!" 2>NUL | findstr /I "!TARGET_PID!" >NUL
            if !errorlevel! equ 0 (
                set STACK_RUNNING=1
                echo [CONFLICT DETECTED] File %%~nxF shows an active process tree is already running on PID: !TARGET_PID!
            )
        )
    )
)

:: 5. BLOCK STARTUP IF ACTIVE SYSTEM BLOCKERS RECOVERED
if !STACK_RUNNING! equ 1 (
    echo.
    echo ========================================================================
    echo BLOCKING STARTUP: STACK PROCESSES DETECTED IN ACTIVE ENVIRONMENT
    echo ========================================================================
    echo Current System Blockers Found:
    for %%F in ("%TMP_DIR%\*.pid") do (
        if not "%%~nxF"=="orchestrator.pid" (
            set /p T_PID=<"%%F"
            tasklist /FI "PID eq !T_PID!" /FO TABLE /NH 2>NUL
        )
    )
    echo.
    echo ACTION REQUIRED: Run 'shutdown_orchestrator.bat' to clear active trees.
    echo ========================================================================
    echo.
    pause
    exit /b
)

:: 6. LAUNCH CENTRAL HUB DISPATCHER ROUTED OUT OF SUBORDINATE BIN DIRECTORY
powershell -NoProfile -ExecutionPolicy Bypass -File "%PROJECT_DIR%bin\Start-Stack.ps1" > "%LOG_DIR%\orchestrator_start.log" 2>&1