# bin\Run-LiteLLM.ps1
# Import the environmental variables safely from configuration boundaries
. "$PSScriptRoot\..\config\env.ps1"

$LogDir = "$PSScriptRoot\..\log"
$TmpDir = "$PSScriptRoot\..\tmp"

Write-Host "Initializing LiteLLM Proxy Engine via Port $env:LITELLM_PORT..." -ForegroundColor Cyan

# Run LiteLLM leveraging your configured path parameters and environmental credentials
$Job = Start-Process litellm -ArgumentList "--config", "$env:LITELLM_CONFIG", "--port", $env:LITELLM_PORT -NoNewWindow -PassThru -RedirectStandardOutput "$LogDir\litellm.log" -RedirectStandardError "$LogDir\litellm_errors.log"

if ($Job) {
    $Job.Id | Out-File "$TmpDir\litellm.pid" -Encoding ascii
}