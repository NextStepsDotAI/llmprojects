# ========================================================================
# 1. ENVIRONMENT & CONTEXT ROUTING (ISOLATED WORKSPACE INHERITANCE)
# ========================================================================
# Inherit execution context from the parent hub and map isolated subdirectories
$BinDir = $PSScriptRoot
$WorkingDir = Split-Path -Parent $BinDir

$LogDir = "$WorkingDir\log"
$TmpDir = "$WorkingDir\tmp"
$ConfigDir = "$WorkingDir\config"

$LiteLLMLog = "$LogDir\litellm.log"
$LiteLLMPidFile = "$TmpDir\litellm.pid"

# Force current executing directory context back to project workspace root
Set-Location $WorkingDir

# ========================================================================
# 2. LOCALIZED NETWORK LOOPBACK BYPASS ISOLATION
# ========================================================================
# Prevent the local proxy runtime from trying to route traffic through any 
# system-wide corporate or network proxy blocks when hitting 127.0.0.1
$env:NO_PROXY = "127.0.0.1,localhost"
$env:no_proxy = "127.0.0.1,localhost"

# ========================================================================
# 3. BACKGROUND DESKTOP PROCESS DISPATCH & TRACING
# ========================================================================
# Spawns a background command wrapper shell to host the LiteLLM router instance.
# Maps configuration directly out of the dedicated \config domain directory.
# Both standard output and detailed debugging traces are piped cleanly to litellm.log.
$Process = Start-Process -FilePath "cmd" -ArgumentList "/c litellm --config `"$ConfigDir\config.yaml`" --host 127.0.0.1 --port 4000 --detailed_debug >> `"$LiteLLMLog`" 2>&1" `
    -NoNewWindow -PassThru

# Record the unique operating system Process ID (PID) to the workspace monitoring area
if ($Process) {
    $Process.Id | Out-File -FilePath $LiteLLMPidFile -Encoding ascii
}