========================================================================
SYSTEM ENVIRONMENT & RUNTIME DEPENDENCIES
========================================================================

1. OPERATING SYSTEM CONSTRAINTS
   - Microsoft Windows 10/11 or Windows Server environment framework
   - PowerShell 5.1+ or PowerShell Core (7.x+) enabled in system path
   - Execution Policy privileges configured to allow local orchestration script runs.
     Verification command (Run as Administrator): 
     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

2. NETWORK & SOCKET BOUNDARIES
   - TCP Port 6006 must be completely free (Allocated to Arize Phoenix Server)
   - TCP Port 4000 must be completely free (Allocated to LiteLLM Proxy Engine)
   - Localhost loopback network routing (127.0.0.1) operational

3. RUNTIME BINARY ENGINE DEPENDENCIES
   - Python 3.10+ executable discovered and verified in the system PATH
   - Pip (Python Package Installer) updated to current standard

4. DIRECTORY & CONFIGURATION Privileges
   - The 'config.yaml' file must reside inside the dedicated 'config/' directory:
     \orchestrator_stack\config\config.yaml
   - Custom environmental injection profiles belong inside the 'env/' directory.
   - All architecture Blueprints and verification requirements belong inside 'specification/'.