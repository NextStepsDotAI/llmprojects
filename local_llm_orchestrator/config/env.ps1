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
$env:LITELLM_LOG    = "INFO"

# --- Database ---
$env:DATABASE_URL = "postgresql://postgres:Password123@127.0.0.1:5432/litellm?pool_timeout=60&connection_limit=10"

# --- Prisma Engine Configuration ---
$env:PRISMA_QUERY_ENGINE_BINARY = "C:\Users\nextstep.ai\.cache\prisma-python\binaries\5.17.0\393aa359c9ad4a4bb28630fb5613f9c281cde053\node_modules\prisma\query-engine-windows.exe"
$env:PRISMA_QUERY_ENGINE_BINARY_TIMEOUT = "60"
$env:PRISMA_CLIENT_CONNECT_TIMEOUT = "30"

# FIX: Value must be quoted string, not bare word
$env:PRISMA_CLIENT_ENGINE_TYPE = "binary"

Write-Host "Workspace environment configurations populated successfully." -ForegroundColor Gray
