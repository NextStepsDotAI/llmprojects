# ========================================================================
# 1. ENVIRONMENT & CONTEXT ROUTING (ISOLATED WORKSPACE INHERITANCE)
# ========================================================================
# Since this script resides inside the \bin subfolder, establish the parent 
# directory as the primary executing root workspace context.
$BinDir = $PSScriptRoot
$WorkingDir = Split-Path -Parent $BinDir
Set-Location $WorkingDir

$LogDir = "$WorkingDir\log"
$TmpDir = "$WorkingDir\tmp"

# Define component log targets
$PhoenixLog = "$LogDir\phoenix.log"
$LiteLLMLog = "$LogDir\litellm.log"
$Timestamp  = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " HUB DISPATCHER: INITIATING WORKSPACE OPERATIONS   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Project Workspace Root: $WorkingDir" -ForegroundColor Gray

# ========================================================================
# 2. DYNAMIC HISTORICAL LOG ROLLING
# ========================================================================
# Inspects existing log files. If present, rolls them over into a timestamped 
# archive before starting new background execution threads.
$LogsToRoll = @(
    @{ Active = $PhoenixLog; Archive = "$LogDir\phoenix_$Timestamp.log"; Name = "Arize Phoenix" },
    @{ Active = $LiteLLMLog;  Archive = "$LogDir\litellm_$Timestamp.log";  Name = "LiteLLM Proxy" }
)

foreach ($LogSetting in $LogsToRoll) {
    if (Test-Path $LogSetting.Active) {
        try {
            Write-Host "Rolling over active log archive for [$($LogSetting.Name)]..." -ForegroundColor Gray
            Move-Item -Path $LogSetting.Active -Destination $LogSetting.Archive -Force -ErrorAction Stop
        } catch {
            # Fallback if a persistent OS file handles constraint prevents moving
            Copy-Item -Path $LogSetting.Active -Destination $LogSetting.Archive -Force
            Clear-Content -Path $LogSetting.Active -ErrorAction SilentlyContinue
        }
    }
}

# ========================================================================
# 3. DECOUPLED INDEPENDENT COMPONENT SPOKE DISPATCH
# ========================================================================

# --- SPOKE 1: ARIZE PHOENIX RUNTIME ---
$PhoenixScript = "$BinDir\Run-Phoenix.ps1"
if (Test-Path $PhoenixScript) {
    Write-Host "Hub Status: Launching isolated Phoenix telemetry spoke..." -ForegroundColor Yellow
    
    # Fire the script in a detached background PowerShell context using system bypass rules
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PhoenixScript`"" -NoNewWindow
    Write-Host "✔ Hub Status: Phoenix execution signal transmitted." -ForegroundColor Green
} else {
    Write-Host "❌ Hub Error: Missing operational component: $PhoenixScript" -ForegroundColor Red
}

# Brief pause to allow the Phoenix server socket sequence to claim port 6006 cleanly
Start-Sleep -Seconds 2

# --- SPOKE 2: LITELLM GATEWAY ROUTER ---
$LiteLLMScript = "$BinDir\Run-LiteLLM.ps1"
if (Test-Path $LiteLLMScript) {
    Write-Host "Hub Status: Launching isolated LiteLLM gateway proxy spoke..." -ForegroundColor Yellow
    
    # Fire the script in a detached background PowerShell context using system bypass rules
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$LiteLLMScript`"" -NoNewWindow
    Write-Host "✔ Hub Status: LiteLLM proxy execution signal transmitted." -ForegroundColor Green
} else {
    Write-Host "❌ Hub Error: Missing operational component: $LiteLLMScript" -ForegroundColor Red
}

# ========================================================================
# 4. DISPATCH COMPLETE - CLEAN DISENGAGEMENT
# ========================================================================
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "All background thread handoffs successful." -ForegroundColor White
Write-Host "Tracking structures populated under \tmp" -ForegroundColor White
Write-Host "Operational timelines running inside \log" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
Start-Sleep -Seconds 2
Exit