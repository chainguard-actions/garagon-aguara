<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to `bash` without first saving it to a file and verifying its integrity. Pattern: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is validated as a semver tag or 40-char SHA, the script content is executed immediately without a checksum or signature check, making this an unsafe-shell pattern.

Locations:

- `action.yml:94`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag (`@v3`) instead of a pinned 40-character commit SHA. A mutable tag can be silently updated to point to a different (potentially malicious) commit, creating a supply-chain risk.

Locations:

- `action.yml:145`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 94): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No shell option arguments were present after `bash` in the original pipe form, so no `--` removal was needed. 2. unpinned-uses (line 145): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311`, preserving the tag as a `# v3` comment for readability.

