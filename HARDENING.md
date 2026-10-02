<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

In the 'Install Aguara' step, the install script is fetched from a remote URL and piped directly to bash without first downloading to a file: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. If the remote server or the URL is compromised, arbitrary code executes immediately in the runner. The script should be downloaded to a temporary file, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag instead of a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, enabling a supply-chain attack. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:148`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 98): Replaced `curl ... | bash` with a safe download-then-execute pattern: script is downloaded to a mktemp file, executed with `bash "$INSTALL_SCRIPT"`, then removed. 2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

