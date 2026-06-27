# ==========================================
# ENVIRONMENT CONFIGURATION (DYNAMIC PATHS)
# ==========================================
$WorkingDir = $PSScriptRoot
Set-Location $WorkingDir

# Define isolated subdirectories
$LogDir = "$WorkingDir\log"
$TmpDir = "$WorkingDir\tmp"

# Automatically ensure directories exist before launching
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
if (-not (Test-Path $TmpDir)) { New-Item -ItemType Directory -Path $TmpDir | Out-Null }

$PhoenixPidFile = "$TmpDir\phoenix.pid"
$LiteLLMPidFile = "$TmpDir\litellm.pid"

# ==========================================
# STRICT CONCURRENCY CHECK (PREVENT RE-SPAWN)
# ==========================================
$IsAlreadyRunning = $false

# 1. Check if Phoenix is active
if (Test-Path $PhoenixPidFile) {
    $OldPhoenixPid = (Get-Content $PhoenixPidFile).Trim()
    if ($OldPhoenixPid -and (Get-Process -Id $OldPhoenixPid -ErrorAction SilentlyContinue)) {
        Write-Host "🛑 Access Denied: Arize Phoenix is already running on PID $OldPhoenixPid." -ForegroundColor Red
        $IsAlreadyRunning = $true
    }
}

# 2. Check if LiteLLM is active
if (Test-Path $LiteLLMPidFile) {
    $OldLiteLLMPid = (Get-Content $LiteLLMPidFile).Trim()
    if ($OldLiteLLMPid -and (Get-Process -Id $OldLiteLLMPid -ErrorAction SilentlyContinue)) {
        Write-Host "🛑 Access Denied: LiteLLM Proxy is already running on PID $OldLiteLLMPid." -ForegroundColor Red
        $IsAlreadyRunning = $true
    }
}

# Abort execution if any active instances exist
if ($IsAlreadyRunning) {
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host "Please run 'shutdown_orchestrator.bat' to stop the current instance before restarting." -ForegroundColor Yellow
    Write-Host "Exiting launcher in 5 seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    Exit
}

# ==========================================
# AUTOMATIC LOG ROLLING SEQUENCE
# ==========================================
$PhoenixLog    = "$LogDir\phoenix.log"
$PhoenixErrLog = "$LogDir\phoenix.err"
$LiteLLMLog    = "$LogDir\litellm.log"
$LiteLLMErrLog = "$LogDir\litellm.err"

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogsToRoll = @(
    @{ Active = $PhoenixLog; Archive = "$LogDir\phoenix_$Timestamp.log" },
    @{ Active = $LiteLLMLog;  Archive = "$LogDir\litellm_$Timestamp.log" }
)

foreach ($LogFile in $LogsToRoll) {
    if (Test-Path $LogFile.Active) {
        try {
            Move-Item -Path $LogFile.Active -Destination $LogFile.Archive -Force -ErrorAction Stop
        } catch {
            Copy-Item -Path $LogFile.Active -Destination $LogFile.Archive -Force
            Clear-Content -Path $LogFile.Active -ErrorAction SilentlyContinue
        }
    }
}

# Set network environment bypass variables
$env:NO_PROXY="127.0.0.1,localhost"
$env:no_proxy="127.0.0.1,localhost"
$env:PHOENIX_COLLECTOR_ENDPOINT="http://127.0.0.1:6006/v1/traces"
$env:OTEL_EXPORTER_OTLP_ENDPOINT="http://127.0.0.1:6006"
$env:OTEL_EXPORTER_OTLP_TRACES_PROTOCOL="http/json"
$env:PRISMA_CLI_BINARY_TARGETS="native"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " STARTING AI DEVELOPMENT STACK (BACKGROUND MODE) " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Remove-Item $PhoenixPidFile, $LiteLLMPidFile, $PhoenixErrLog, $LiteLLMErrLog -ErrorAction SilentlyContinue

# ==========================================
# 1. LAUNCH ARIZE PHOENIX
# ==========================================
Write-Host "Launching Arize Phoenix on port 6006..." -ForegroundColor Yellow

$PhoenixProcess = Start-Process -FilePath "python" -ArgumentList "-m phoenix.server.main launch" `
    -NoNewWindow -PassThru `
    -RedirectStandardOutput $PhoenixLog `
    -RedirectStandardError $PhoenixErrLog

if ($PhoenixProcess) {
    $PhoenixProcess.Id | Out-File -FilePath $PhoenixPidFile -Encoding ascii
    Write-Host "✔ Phoenix started successfully. PID: $($PhoenixProcess.Id)" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start Phoenix." -ForegroundColor Red
}

Start-Sleep -Seconds 2

# ==========================================
# 2. LAUNCH LITELLM PROXY
# ==========================================
Write-Host "Launching LiteLLM Proxy on port 4000..." -ForegroundColor Yellow

$LiteLLMProcess = Start-Process -FilePath "litellm" -ArgumentList "--config config.yaml --host 127.0.0.1 --port 4000 --detailed_debug" `
    -NoNewWindow -PassThru `
    -RedirectStandardOutput $LiteLLMLog `
    -RedirectStandardError $LiteLLMErrLog

if ($LiteLLMProcess) {
    $LiteLLMProcess.Id | Out-File -FilePath $LiteLLMPidFile -Encoding ascii
    Write-Host "✔ LiteLLM Proxy started successfully. PID: $($LiteLLMProcess.Id)" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start LiteLLM Proxy." -ForegroundColor Red
}

# ==========================================
# 3. SELF-DESTRUCT ORCHESTRATOR WINDOW
# ==========================================
Write-Host "--------------------------------------------------" -ForegroundColor Cyan
Write-Host "All processes are running silently in the background." -ForegroundColor White
Write-Host "Outputs are structured under \log and \tmp subfolders." -ForegroundColor White

# Force a brief pause so the console output can be read if launched interactively
Start-Sleep -Seconds 5

Exit