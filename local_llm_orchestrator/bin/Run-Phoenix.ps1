# bin\Run-Phoenix.ps1
# Import the environmental variables safely
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"
$CombinedLog = "$LogDir\phoenix_combined.log"

# Clean up previous log for a fresh start
if (Test-Path $CombinedLog) { Remove-Item $CombinedLog }

Write-Host "Initializing Phoenix Telemetry Engine via Port $env:PHOENIX_PORT..." -ForegroundColor Cyan

# Use a command string to ensure Phoenix is detached and output is consolidated.
# *> redirects both Standard Output (1) and Standard Error (2) to the log file.
# Corrected command: Merge Error (2) into Output (1), then redirect to file
$PhoenixCommand = "phoenix serve --port $env:PHOENIX_PORT 2>&1 > '$CombinedLog'"

# Use Start-Process with -WindowStyle Hidden to detach the process completely
$Job = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command &{$PhoenixCommand}" -PassThru -WindowStyle Hidden

if ($Job) {
    $Job.Id | Out-File "$TmpDir\phoenix.pid" -Encoding ascii
}