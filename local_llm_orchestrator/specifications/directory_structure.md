D:\llm_project\                        <-- Main Workspace Context
└── orchestrator_stack\                <-- Isolated Project Directory Root
    ├── start_orchestrator.bat         <-- Pre-flight lock validator & gateway entrypoint
    ├── shutdown_orchestrator.bat      <-- Teardown entrypoint
    │
    ├── specification/                 <-- NEW: Project Documentation and Verification Rules
    │   ├── README.md                  <-- Complete architectural blueprint documentation
    │   └── prerequisites.txt          <-- Infrastructure dependency verification metrics
    │
    ├── config/                        <-- Static Application Configuration Directory
    │   └── config.yaml                <-- LiteLLM proxy routing rules configuration
    │
    ├── env/                           <-- Environment Variables Profiles Directory
    │
    ├── log/                           <-- AUTO-GENERATED: Operations logs folder
    ├── tmp/                           <-- AUTO-GENERATED: Tracking PID folder
    │
    └── bin/                           <-- Static Code Directory (Kept 100% Clean)
        ├── Start-Stack.ps1            <-- Central Router Hub
        ├── Stop-Stack.ps1             <-- Teardown Engine
        ├── Run-Phoenix.ps1            <-- Component Spoke: Phoenix Lifecycle
        └── Run-LiteLLM.ps1            <-- Component Spoke: LiteLLM Proxy Lifecycle