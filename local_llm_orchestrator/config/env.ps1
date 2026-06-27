# ========================================================================
# CENTRALIZED DESKTOP ENVIRONMENT CONFIGURATION & REGISTRY (config\env.ps1)
# ========================================================================
# Force Python to use UTF-8 encoding to avoid UnicodeEncodeError in LiteLLM
$env:PYTHONIOENCODING = "utf-8"
$env:LC_ALL = "en_US.UTF-8"

# --- Component Runtime Ports ---
$env:PHOENIX_PORT = 6006
$env:LITELLM_PORT = 4000

# --- Filepath/Routing Definitions ---
# Dynamically points everything relative to your project workspace structure
$WorkspaceRoot      = Split-Path -Parent $PSScriptRoot
$env:LITELLM_CONFIG = "$WorkspaceRoot\config\config.yaml"

# --- Provider Credentials / Mock Keys ---
# NOTE: Replace these with your actual keys locally. 
# Keep this file out of your main git pushes if secrets are added!
$env:OPENAI_API_KEY = "sk-mock-key-for-local-routing-boundaries"
$env:AWS_REGION     = "us-east-1"

Write-Host "Workspace environment configurations populated successfully." -ForegroundColor Gray