# bin\Run-Phoenix.ps1
# Import the environmental variables safely
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"
$CombinedLog = "$LogDir\phoenix_combined.log"

# Clean up previous log for a fresh start
if (Test-Path $CombinedLog) { Remove-Item $CombinedLog }

Write-Host "Initializing Phoenix Telemetry Engine via Port $env:PHOENIX_PORT..." -ForegroundColor Cyan

# FIX: Use explicit venv path instead of bare 'phoenix' command
$VenvRoot = "$PSScriptRoot\..\env\.venv-phoenix"
$PhoenixExe = "$VenvRoot\Scripts\phoenix.exe"

if (-not (Test-Path $PhoenixExe)) {
    Write-Error "Phoenix executable not found at: $PhoenixExe"
    Write-Error "Please ensure the venv is set up: pip install arize-phoenix"
    exit 1
}

$PhoenixCommand = "& '$PhoenixExe' serve --port $env:PHOENIX_PORT 2>&1 > '$CombinedLog'"

# Use Start-Process with -WindowStyle Hidden to detach the process completely
$Job = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command &{$PhoenixCommand}" -PassThru -WindowStyle Hidden

if ($Job) {
    $Job.Id | Out-File "$TmpDir\phoenix.pid" -Encoding ascii
}

