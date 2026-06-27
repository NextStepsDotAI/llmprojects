# bin\Run-Phoenix.ps1
# Import the environmental variables safely from configuration boundaries
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"

Write-Host "Initializing Phoenix Telemetry Engine via Port $env:PHOENIX_PORT..." -ForegroundColor Cyan

# Spawn the background collector daemon tracking the designated port assignment
$Job = Start-Process phoenix -ArgumentList "start", "--port", $env:PHOENIX_PORT -NoNewWindow -PassThru -RedirectStandardOutput "$LogDir\phoenix.log" -RedirectStandardError "$LogDir\phoenix_errors.log"

if ($Job) {
    $Job.Id | Out-File "$TmpDir\phoenix.pid" -Encoding ascii
}