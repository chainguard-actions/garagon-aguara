<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, making this a supply-chain risk.

Locations:

- `action.yml:136`

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads `install.sh` from a remote URL and pipes it directly to `bash` without first saving it to a file for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. If the remote content is compromised or the URL is redirected, arbitrary code executes immediately on the runner.

Locations:

- `action.yml:94`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, unsafe-shell

**Notes:**

1. Pinned `github/codeql-action/upload-sarif@v3` to its immutable commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b`, preserving the `# v3` tag comment for readability. 2. Replaced the `curl ... | bash` pipe in the 'Install Aguara' step with a safe two-step approach: download `install.sh` to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. The original had no `--` separator, so no argument adjustment was needed.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (derived from runner.temp context) was being written directly to $GITHUB_PATH without newline sanitization. Added a sanitization step using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` to strip newlines and carriage returns before writing to $GITHUB_PATH, preventing environment injection attacks.

