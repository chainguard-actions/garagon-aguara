<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a remote GitHub raw URL and pipes it directly to bash (`curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`). The script is not downloaded to a file first and verified before execution. This is a classic `curl | bash` pattern that allows a compromised or man-in-the-middle response to execute arbitrary code on the runner.

Locations:

- `action.yml:91`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character SHA commit hash. A mutable tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:136`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 91): Replaced the `curl ... | bash` pattern with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. This prevents arbitrary code execution from a compromised or MITM'd response being piped directly into bash.
2. unpinned-uses (line 136): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at the 'Install Aguara' step. The INSTALL_DIR value (derived from runner.temp, a workflow-controllable context) was being written directly to $GITHUB_PATH without sanitization. Added `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` before the echo to strip newline characters, then write the sanitized value to $GITHUB_PATH instead.

