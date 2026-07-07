# bin\Run-LiteLLM.ps1
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"
$CombinedLog = "$LogDir\litellm_combined.log"

if (Test-Path $CombinedLog) { Remove-Item $CombinedLog }

Write-Host "Initializing LiteLLM Proxy Engine via Port $env:LITELLM_PORT..." -ForegroundColor Cyan

# FIX: Use explicit venv path instead of bare 'litellm' command
# This ensures the correct Python environment is always used
$VenvRoot = "$PSScriptRoot\..\env\.venv"
$LiteLLMExe = "$VenvRoot\Scripts\litellm.exe"

if (-not (Test-Path $LiteLLMExe)) {
    Write-Error "LiteLLM executable not found at: $LiteLLMExe"
    Write-Error "Please ensure the venv is set up: python -m venv env\.venv && pip install litellm[proxy]==1.72.6"
    exit 1
}

$LiteCommand = "& '$LiteLLMExe' --config '$env:LITELLM_CONFIG' --port $env:LITELLM_PORT 2>&1 > '$CombinedLog'"

$Job = Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -Command &{$LiteCommand}" -PassThru -WindowStyle Hidden

if ($Job) {
    $Job.Id | Out-File "$TmpDir\litellm.pid" -Encoding ascii
}
