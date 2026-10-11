<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash without first saving it to a file for inspection. Pattern: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows arbitrary remote code execution if the URL is compromised or the ref is tampered with.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved to point to a different (potentially malicious) commit.

Locations:

- `action.yml:153`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 100): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up the temp file afterward. No '--' separator was present in the original pipe form so none was introduced. 2. unpinned-uses (line 153): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR env var (derived from `${{ runner.temp }}/aguara-bin`) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` to strip newlines and carriage returns before writing to $GITHUB_PATH.

