# bin\Run-LiteLLM.ps1
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"
$CombinedLog = "$LogDir\litellm_combined.log"

if (Test-Path $CombinedLog) { Remove-Item $CombinedLog }

Write-Host "Initializing LiteLLM Proxy Engine via Port $env:LITELLM_PORT..." -ForegroundColor Cyan

# Use 2>&1 to merge Error (2) into Output (1), then redirect (>) to the file.
# This prevents the 'NativeCommandError' because PowerShell no longer sees these as separate streams.
$LiteCommand = "litellm --config '$env:LITELLM_CONFIG' --port $env:LITELLM_PORT 2>&1 > '$CombinedLog'"

$Job = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command &{$LiteCommand}" -PassThru -WindowStyle Hidden

if ($Job) {
    $Job.Id | Out-File "$TmpDir\litellm.pid" -Encoding ascii
}