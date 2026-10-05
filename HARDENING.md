<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from GitHub raw content and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe shell pattern — if the remote URL is compromised or the ref is manipulated, arbitrary code executes immediately in the runner without any integrity check.

Locations:

- `action.yml:83`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character SHA commit hash. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:106`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 83): Replaced `curl ... | bash` with a safe two-step pattern: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This eliminates the risk of piping untrusted remote content directly to bash. 2. unpinned-uses (line 106): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

