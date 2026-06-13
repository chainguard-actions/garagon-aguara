<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely fetched script directly to bash without saving it to a file first: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated to be a semver tag or 40-char SHA, piping remote content directly to a shell interpreter is an unsafe pattern — the script should be downloaded to a temporary file, verified, and then executed separately.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character commit SHA. If the tag is moved (e.g. by a supply chain compromise), the action will silently execute different code. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:143`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a safe pattern: download the install script to a temp file via `mktemp`, execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. 2. unpinned-uses (line 143): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `dd903d2e4f5405488e5ef1422510ee31c8b32357` with the original tag preserved as a comment.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (derived from `${{ runner.temp }}/aguara-bin`) was previously written directly to $GITHUB_PATH without sanitization. The fix adds a sanitization step using `safe_install_dir=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')` before writing to $GITHUB_PATH, preventing potential newline injection attacks that could manipulate the PATH environment variable.

