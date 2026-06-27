# ========================================================================
# 1. ENVIRONMENT & CONTEXT ROUTING (ISOLATED WORKSPACE INHERITANCE)
# ========================================================================
# Inherit execution context from the parent hub and map local storage directories
$BinDir = $PSScriptRoot
$WorkingDir = Split-Path -Parent $BinDir

$LogDir = "$WorkingDir\log"
$TmpDir = "$WorkingDir\tmp"

$PhoenixLog = "$LogDir\phoenix.log"
$PhoenixPidFile = "$TmpDir\phoenix.pid"

# ========================================================================
# 2. LOCALIZED METRIC ENVIRONMENT VARIABLES ISOLATION
# ========================================================================
# Bound the Arize Phoenix collector telemetry pipelines explicitly to localhost
$env:PHOENIX_COLLECTOR_ENDPOINT = "http://127.0.0.1:6006/v1/traces"
$env:OTEL_EXPORTER_OTLP_ENDPOINT = "http://127.0.0.1:6006"
$env:OTEL_EXPORTER_OTLP_TRACES_PROTOCOL = "http/json"

# ========================================================================
# 3. BACKGROUND DESKTOP PROCESS DISPATCH & TRACING
# ========================================================================
# Spawns a background command wrapper shell to host the Python instance.
# All standard output and runtime execution errors are piped directly to phoenix.log.
$Process = Start-Process -FilePath "cmd" -ArgumentList "/c python -m phoenix.server.main serve >> `"$PhoenixLog`" 2>&1" `
    -NoNewWindow -PassThru

# Record the unique operating system Process ID (PID) to the workspace monitoring area
if ($Process) {
    $Process.Id | Out-File -FilePath $PhoenixPidFile -Encoding ascii
}