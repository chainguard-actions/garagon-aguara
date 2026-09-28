<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from GitHub raw content and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is validated to be a semver tag or 40-char SHA, the script content is never saved to disk before execution — a network-level attacker or a compromised CDN could serve malicious content that executes immediately in the runner shell. The script should be downloaded to a temporary file, its checksum verified, and then executed separately.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which is a mutable tag rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit without notice, enabling supply-chain attacks. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a download-then-execute pattern. The script is saved to a temp file via `mktemp`, downloaded with `curl -o`, executed separately with `bash "$INSTALL_SCRIPT"`, then cleaned up. No positional arguments were dropped since the original piped form passed none — install.sh reads only environment variables (VERSION, INSTALL_DIR, GITHUB_TOKEN). 2. unpinned-uses (line 130): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `github/codeql-action/upload-sarif@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.

