# Local AI Infrastructure Orchestrator

An isolated, decoupled, and self-healing local runner architecture built to manage independent AI development stacks cleanly inside background contexts on a Windows environment framework.

## 1. Architectural Philosophy: Hub-and-Spoke

This project establishes a clean **Hub-and-Spoke** topology, separating runtime processing mechanisms from static script configurations. It forces all operational side-effects (`log/` and `tmp/`) to stay outside your version-controlled binaries directory.

* **The Gateway Entrypoints (`*.bat` at Project Root):** Parent wrappers that execute system-level validation sweeps natively *before* launching background shells, avoiding silent execution blocks or log file locks.
* **The Project Domains (`specification/`, `config/`, `env/`):** Explicitly separated workspace boundaries. Technical manifests live inside `specification/`, mapping schemas live inside `config/`, and variable injections remain inside `env/`.
* **The Router Hub (`bin\Start-Stack.ps1`):** The central engine traffic controller. It orchestrates system-wide tasks like automatic historical log-rolling and worker script routing without maintaining service-specific environments.
* **The Component Spokes (`bin\Run-*.ps1`):** Completely decoupled script spokes. Each spoke exclusively owns its specific operational runtime, environment variables, socket bindings, and unified telemetry streams.

---

## 2. Process ID (PID) Tracing and Lifecycle Map

To eliminate configuration maintenance when extending the stack, runtime management relies entirely on stateless filesystem monitoring rather than hardcoded process name lookups.

### Startup Tracing Lifecycle
1. `start_orchestrator.bat` fires, discovers its active environment context, and writes its parent shell execution ID to `tmp\orchestrator.pid`.
2. The orchestrator runs a lookahead wildcard match targeting `tmp\*.pid`. It parses the internal values of found markers and cross-references them with the live Windows process framework:
   ```cmd
   tasklist /FI "PID eq !TARGET_PID!"