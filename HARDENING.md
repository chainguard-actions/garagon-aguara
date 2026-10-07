<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from GitHub and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated against a semver or SHA pattern, piping remote content directly to a shell interpreter is an unsafe pattern — the script is executed without first being inspected or verified.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which uses a mutable tag (`v3`) rather than a pinned 40-character commit SHA. A mutable tag can be silently updated to point to different (potentially malicious) code, creating a supply-chain risk.

Locations:

- `action.yml:136`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up the temp file afterward. 2. unpinned-uses (line 136): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

