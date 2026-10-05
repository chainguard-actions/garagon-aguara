<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely fetched script directly to bash without first saving it to a file for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows arbitrary code execution from a remote source without any integrity verification of the script content before execution.

Locations:

- `action.yml:89`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:115`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 89): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up the temp file afterward. This eliminates arbitrary code execution from a piped remote script. 2. unpinned-uses (line 115): Replaced `github/codeql-action/upload-sarif@v3` with the full commit SHA `github/codeql-action/upload-sarif@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3` to pin to an immutable reference.

