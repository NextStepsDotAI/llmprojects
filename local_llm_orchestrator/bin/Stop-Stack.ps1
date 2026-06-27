# ========================================================================
# 1. ENVIRONMENT & DETACHED TEARDOWN CORE CONTEXT
# ========================================================================
# Since this script lives inside the \bin subfolder, capture the parent 
# directory to synchronize tracking across the workspace.
$BinDir = $PSScriptRoot
$WorkingDir = Split-Path -Parent $BinDir
$TmpDir = "$WorkingDir\tmp"

Write-Host "==================================================" -ForegroundColor Magenta
Write-Host " TEARDOWN HUB: SWEEPING COMPONENT STACK ENVIRONMENTS " -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "Scanning workspace target tracking directory: $TmpDir" -ForegroundColor Gray

# ========================================================================
# 2. DYNAMIC WORKSPACE COMPONENT TREE ELIMINATION
# ========================================================================
# Inspects the tmp/ directory dynamically. This allows adding new component 
# spokes without rewriting the teardown script.
if (Test-Path "$TmpDir\*.pid") {
    $PidFiles = Get-ChildItem -Path "$TmpDir\*.pid"
    
    foreach ($File in $PidFiles) {
        # Skip the parent orchestrator tracker file to handle it exclusively at exit
        if ($File.Name -eq "orchestrator.pid") { continue }
        
        $PidValue = (Get-Content $File.FullName).Trim()
        if ($PidValue) {
            Write-Host "Evaluating active tracking register: [$($File.Name)] -> Target Process ID: $PidValue" -ForegroundColor Yellow
            
            # Cross-reference with live OS process records
            if (Get-Process -Id $PidValue -ErrorAction SilentlyContinue) {
                Write-Host "Executing cascading tree kill on root wrapper PID $PidValue and all child worker daemons..." -ForegroundColor DarkYellow
                
                # Enforce deep forceful tree teardown via taskkill (/T /F) to unlock ports
                taskkill /PID $PidValue /T /F | Out-Null
                Write-Host "✔ Cleaned up component process architecture successfully." -ForegroundColor Green
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