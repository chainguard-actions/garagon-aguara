<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first downloading and verifying it: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. If the remote URL is compromised or the ref is manipulated, arbitrary code executes immediately on the runner.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which is a mutable tag rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:143`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a safe pattern: download install.sh to a temp file via `mktemp`, execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This allows inspection before execution and prevents arbitrary code from running directly from a pipe. 2. unpinned-uses (line 143): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `github/codeql-action/upload-sarif@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3` to prevent supply-chain attacks via mutable tag references.

