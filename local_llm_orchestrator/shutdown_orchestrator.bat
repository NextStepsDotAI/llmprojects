@echo off
setlocal enabledelayedexpansion

:: 1. SET EXPLICIT WORKSPACE PROJECT PATH CONTEXT
set "PROJECT_DIR=%~dp0"
set "TMP_DIR=%PROJECT_DIR%tmp"
set "LOG_DIR=%PROJECT_DIR%log"
set "SHUTDOWN_LOG=%LOG_DIR%\orchestrator_stop.log"

:: 2. AUTO-GENERATE MISSING ARTIFACT FOLDERS TO PREVENT REDIRECTION CRASHES
if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: 3. INITIALIZE LOG FILE HOOK
echo ======================================================================== > "%SHUTDOWN_LOG%"
echo SHUTDOWN SEQUENCE INITIATED AT: %DATE% %TIME% >> "%SHUTDOWN_LOG%"
echo ======================================================================== >> "%SHUTDOWN_LOG%"

echo ========================================================================
echo INITIATING AI INFRASTRUCTURE TEARDOWN
echo ========================================================================
echo Logging execution trace directly to: %SHUTDOWN_LOG%
echo.

:: 4. DYNAMIC ENVIRONMENT INSPECTION BLOCK
echo [STAGE 1] SCANNING FOR TRACKED PROCESS TREES...
echo [STAGE 1] SCANNING FOR TRACKED PROCESS TREES... >> "%SHUTDOWN_LOG%"

set FOUND_TARGETS=0

if exist "%TMP_DIR%\*.pid" (
    for %%F in ("%TMP_DIR%\*.pid") do (
        if not "%%~nxF"=="orchestrator.pid" (
            set /p TARGET_PID=<"%%F"
            
            :: Verify if the tracked PID is actively registered in the OS
            tasklist /FI "PID eq !TARGET_PID!" 2>NUL | findstr /I "!TARGET_PID!" >NUL
            if !errorlevel! equ 0 (
                set /a FOUND_TARGETS+=1
                echo ------------------------------------------------------------------------
                echo ------------------------------------------------------------------------ >> "%SHUTDOWN_LOG%"
                echo TARGET FOUND: Component Tracking File [%%~nxF] maps to Active PID: !TARGET_PID!
                echo TARGET FOUND: Component Tracking File [%%~nxF] maps to Active PID: !TARGET_PID! >> "%SHUTDOWN_LOG%"
                
                :: Print Parent Process details
                echo   [PARENT WRAPPER]:
                echo   [PARENT WRAPPER]: >> "%SHUTDOWN_LOG%"
                tasklist /FI "PID eq !TARGET_PID!" /FO TABLE >> "%SHUTDOWN_LOG%"
                tasklist /FI "PID eq !TARGET_PID!" /FO TABLE /NH
                
                :: Query the OS for downstream child engines matching the tree branch
                echo   [CHILD RUNTIME ENGINES IN TREE]:
                echo   [CHILD RUNTIME ENGINES IN TREE]: >> "%SHUTDOWN_LOG%"
                wmic process where "ParentProcessId=!TARGET_PID!" get Name, ProcessId 2>NUL | findstr /V "Name ProcessId" > temp_children.txt
                
                set /a CHILD_COUNT=0
                for /f "tokens=1,2" %%A in (temp_children.txt) do (
                    set /a CHILD_COUNT+=1
                    echo     - Found Child Engine: %%A (PID: %%B)
                    echo     - Found Child Engine: %%A (PID: %%B) >> "%SHUTDOWN_LOG%"
                )
                if !CHILD_COUNT! equ 0 (
                    echo     - No active sub-children detected.
                    echo     - No active sub-children detected. >> "%SHUTDOWN_LOG%"
                )
                del temp_children.txt 2>NUL
            ) else (
                echo Stale tracking marker cleared: %%~nxF (PID !TARGET_PID! was already dead)
                echo Stale tracking marker cleared: %%~nxF (PID !TARGET_PID! was already dead) >> "%SHUTDOWN_LOG%"
                del "%%F" 2>NUL
            )
        )
    )
)

if !FOUND_TARGETS! equ 0 (
    echo No active process components found running in this workspace.
    echo No active process components found running in this workspace. >> "%SHUTDOWN_LOG%"
    goto :CLEANUP
)

echo.
echo ------------------------------------------------------------------------
echo [STAGE 2] EXECUTING RECURSIVE TASK TERMINATION
echo [STAGE 2] EXECUTING RECURSIVE TASK TERMINATION >> "%SHUTDOWN_LOG%"
echo ------------------------------------------------------------------------

:: 5. TARGETED DEEP CASCADING TERMINATION LOOP
if exist "%TMP_DIR%\*.pid" (
    for %%F in ("%TMP_DIR%\*.pid") do (
        if not "%%~nxF"=="orchestrator.pid" (
            set /p TARGET_PID=<"%%F"
            
            tasklist /FI "PID eq !TARGET_PID!" 2>NUL | findstr /I "!TARGET_PID!" >NUL
            if !errorlevel! equ 0 (
                echo Terminating process tree root PID !TARGET_PID! (%%~nxF)...
                echo Terminating process tree root PID !TARGET_PID! (%%~nxF)... >> "%SHUTDOWN_LOG%"
                
                :: Run forceful, recursive tree kill (/T /F) and capture errors to the log
                taskkill /PID !TARGET_PID! /T /F >> "%SHUTDOWN_LOG%" 2>&1
                if !errorlevel! equ 0 (
                    echo ✔ Successfully cleared tree branch.
                    echo ✔ Successfully cleared tree branch. >> "%SHUTDOWN_LOG%"
                ) else (
                    echo ❌ Error encountered during tree termination. Review log.
                    echo ❌ Error encountered during tree termination. >> "%SHUTDOWN_LOG%"
                )
            )
            del "%%F" 2>NUL
        )
    )
)

:CLEANUP
:: 6. ERASE SELF-MARKERS AND SHUTDOWN PARENT DELEGATION
if exist "%TMP_DIR%\orchestrator.pid" del "%TMP_DIR%\orchestrator.pid" 2>NUL

echo ------------------------------------------------------------------------
echo Teardown process complete. Environment context is pristine.
echo Teardown process complete. Environment context is pristine. >> "%SHUTDOWN_LOG%"
echo ======================================================================== >> "%SHUTDOWN_LOG%"
echo.

pause