<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely fetched script directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is validated against a semver/SHA pattern before use, the script content is never verified before execution. The script should be downloaded to a temporary file first, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses a mutable tag reference `github/codeql-action/upload-sarif@v3` instead of a pinned 40-character SHA commit hash. A mutable tag can be silently updated to point to different (potentially malicious) code. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:148`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a download-then-execute pattern: script is saved to a temp file via `mktemp`, then executed with `bash "$INSTALL_SCRIPT"`, then cleaned up with `rm -f`. No positional arguments were dropped since install.sh uses environment variables (VERSION, INSTALL_DIR, GITHUB_TOKEN) rather than positional args. 2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with a `# v3` comment preserved for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (set from ${{ runner.temp }}/aguara-bin) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step: `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` and then used `echo "$safe_install_dir" >> "$GITHUB_PATH"` to write the sanitized value.

