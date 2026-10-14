<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a remote URL and pipes it directly to bash without first saving it to a file for inspection. Pattern: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated against a semver/SHA pattern, piping remote content directly to a shell interpreter is an unsafe practice that bypasses any opportunity to inspect the downloaded script before execution.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag (`@v3`) rather than a pinned 40-character commit SHA. A mutable tag can be silently updated to point to different (potentially malicious) code. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:138`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 98): Replaced `curl ... | bash` with a safe download-then-execute pattern: the script is downloaded to a temp file via `mktemp`, executed with `bash "$INSTALL_SCRIPT"`, then cleaned up with `rm -f`. No '--' was needed since the original pipe form had no arguments after `bash`. 2. unpinned-uses (line 138): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

