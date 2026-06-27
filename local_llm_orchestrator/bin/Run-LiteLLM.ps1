# bin\Run-LiteLLM.ps1
# Import the environmental variables safely
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"
$CombinedLog = "$LogDir\litellm_combined.log"

# Clean up previous log if it exists to ensure we only see the latest crash/run
if (Test-Path $CombinedLog) { Remove-Item $CombinedLog }

Write-Host "Initializing LiteLLM Proxy Engine via Port $env:LITELLM_PORT..." -ForegroundColor Cyan

# Use a command string to ensure LiteLLM is detached and output is consolidated.
# *> redirects both Standard Output (1) and Standard Error (2) to the log file.
$LiteCommand = "litellm --config '$env:LITELLM_CONFIG' --port $env:LITELLM_PORT *> '$CombinedLog'"

# Use Start-Process with -WindowStyle Hidden to detach the process completely
$Job = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command &{$LiteCommand}" -PassThru -WindowStyle Hidden

if ($Job) {
    $Job.Id | Out-File "$TmpDir\litellm.pid" -Encoding ascii
}