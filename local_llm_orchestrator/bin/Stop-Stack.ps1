# ========================================================================
# 1. ENVIRONMENT & DETACHED TEARDOWN CORE CONTEXT
# ========================================================================
$BinDir = $PSScriptRoot
$WorkingDir = Split-Path -Parent $BinDir
$TmpDir = "$WorkingDir\tmp"

Write-Host "==================================================" -ForegroundColor Magenta
Write-Host " TEARDOWN HUB: GRACEFUL COMPONENT STACK ENVIRONMENTS " -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "Scanning workspace target tracking directory: $TmpDir" -ForegroundColor Gray

# ========================================================================
# 2. DYNAMIC TWO-STAGE PROCESS TEARDOWN (GRACEFUL -> FORCEFUL)
# ========================================================================
if (Test-Path "$TmpDir\*.pid") {
    $PidFiles = Get-ChildItem -Path "$TmpDir\*.pid"
    
    foreach ($File in $PidFiles) {
        # Skip the parent orchestrator tracker file to handle it exclusively at exit
        if ($File.Name -eq "orchestrator.pid") { continue }
        
        $PidValue = (Get-Content $File.FullName).Trim()
        if ($PidValue) {
            Write-Host "Evaluating active tracking register: [$($File.Name)] -> Target PID: $PidValue" -ForegroundColor Yellow
            
            # Cross-reference with live OS process records
            $Process = Get-Process -Id $PidValue -ErrorAction SilentlyContinue
            
            if ($Process) {
                # --- STAGE 1: Graceful Close ---
                Write-Host "Stage 1: Issuing close signal to PID $PidValue (allowing data flushing)..." -ForegroundColor Cyan
                
                # CloseMainWindow tells GUI apps to close, while letting CLI apps process standard exit signals.
                # Stop-Process without -Force behaves gracefully where supported.
                $Process.CloseMainWindow() | Out-Null
                $Process | Stop-Process -ErrorAction SilentlyContinue
                
                # Wait for up to 3 seconds for the process to exit cleanly
                $TimeoutSec = 3
                $ElapsedSec = 0
                while ((Get-Process -Id $PidValue -ErrorAction SilentlyContinue) -and ($ElapsedSec -lt $TimeoutSec)) {
                    Start-Sleep -Seconds 1
                    $ElapsedSec++
                }
                
                # --- STAGE 2: Forceful Escalation (If Still Running) ---
                if (Get-Process -Id $PidValue -ErrorAction SilentlyContinue) {
                    Write-Warning "PID $PidValue refused to exit within $TimeoutSec seconds. Escalating to forceful tree kill..."
                    taskkill /PID $PidValue /T /F | Out-Null
                    Write-Host "✖ Forcefully terminated process tree." -ForegroundColor Red
                } else {
                    Write-Host "✔ Component exited gracefully." -ForegroundColor Green
                }
            } else {
                Write-Host "Notice: Monitored PID $PidValue has already been terminated." -ForegroundColor Gray
            }
        }
        
        # Safe destruction of tracking file marker
        Remove-Item $File.FullName -Force
    }
} else {
    Write-Host "Notice: No active component tracking structures found inside the workspace." -ForegroundColor Gray
}

# ========================================================================
# 3. ROOT ENVIRONMENT RESETS & RECOVERY
# ========================================================================
if (Test-Path "$TmpDir\orchestrator.pid") { 
    Remove-Item "$TmpDir\orchestrator.pid" -Force 
}

Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "Teardown routine complete. Core environment is pristine." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Magenta
Start-Sleep -Seconds 2