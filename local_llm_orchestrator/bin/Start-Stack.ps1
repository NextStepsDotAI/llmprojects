# ========================================================================
# 1. PLATFORM CONFIGURATION & ENVIRONMENT ENVIRONMENT MAPPINGS
# ========================================================================
$BinDir = $PSScriptRoot
$WorkingDir = Split-Path -Parent $BinDir
$TmpDir = "$WorkingDir\tmp"
$LogDir = "$WorkingDir\log"

# Clean baseline dynamic folder setup
if (-not (Test-Path $TmpDir)) { New-Item -ItemType Directory -Path $TmpDir | Out-Null }
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

Write-Host "==================================================" -ForegroundColor Green
Write-Host " STARTUP HUB: INITIALIZING REFACTORED BACKGROUND SPOKES " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# ========================================================================
# 2. REUSABLE READINESS PROBE FUNCTION
# ========================================================================
function Test-ComponentReadiness {
    param (
        [string]$ComponentName,
        [int]$Port,
        [int]$MaxRetries = 5,
        [int]$DelaySeconds = 2
    )

    Write-Host "--> Initiating readiness probe for $ComponentName on port $Port..." -ForegroundColor Cyan
    $RetryCount = 0
    $IsReady = $false

    while ($RetryCount -lt $MaxRetries) {
        # Check if the port is actively accepting connections
        $Connection = Test-NetConnection -ComputerName localhost -Port $Port -InformationLevel Quiet
        
        if ($Connection) {
            $IsReady = $true
            break
        }

        $RetryCount++
        Write-Host "    [Attempt $RetryCount/$MaxRetries] Port $Port not responding yet. Retrying in $DelaySeconds seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds $DelaySeconds
    }

    if ($IsReady) {
        Write-Host "✔ $ComponentName is fully live, responsive, and bound to port $Port." -ForegroundColor Green
        return $true
    } else {
        Write-Error "✖ Critical: $ComponentName failed readiness probe on port $Port within the timeout window."
        return $false
    }
}

# Track the primary orchestrator container handle 
$ParentPid = $PID
$ParentPid | Out-File "$TmpDir\orchestrator.pid" -Encoding ascii

# ========================================================================
# 3. SPOKE INVOCATIONS WITH HEALTH PROBING
# ========================================================================
# Explicitly load environment definitions first to ensure values exist in the parent loop
. "$BinDir\..\config\env.ps1"

# --- Spoke 1: Telemetry Dashboard (Phoenix) ---
Write-Host "Launching Telemetry Engine..." -ForegroundColor Gray
& "$BinDir\Run-Phoenix.ps1"
$PhoenixReady = Test-ComponentReadiness -ComponentName "Arize Phoenix" -Port $env:PHOENIX_PORT

# --- Spoke 2: Model Gateway Proxy (LiteLLM) ---
if ($PhoenixReady) {
    Write-Host "Launching Model Gateway Proxy..." -ForegroundColor Gray
    & "$BinDir\Run-LiteLLM.ps1"
    $LiteLLMReady = Test-ComponentReadiness -ComponentName "LiteLLM Proxy" -Port $env:LITELLM_PORT
}

# ========================================================================
# 4. FINALIZATION
# ========================================================================
if ($PhoenixReady -and $LiteLLMReady) {
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "All background components verified healthy. Workspace ready!" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
} else {
    Write-Host "==================================================" -ForegroundColor Red
    Write-Warning "Workspace initialization incomplete. One or more services failed to start properly."
    Write-Host "==================================================" -ForegroundColor Red
}