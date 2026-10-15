<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable tag (`v3`) instead of a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, enabling supply-chain attacks.

Locations:

- `action.yml:63`

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to `bash` without first saving it to disk for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. If the remote URL is compromised or the ref is manipulated, arbitrary code executes immediately on the runner.

Locations:

- `action.yml:80`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, unsafe-shell

**Notes:**

1. Pinned `github/codeql-action/upload-sarif@v3` to its full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311`, preserving the tag as a comment.
2. Fixed the unsafe curl-pipe-to-bash pattern in the 'Install Aguara' step: the script is now downloaded to a temp file via `mktemp` and `-o "$INSTALL_SCRIPT"`, then executed with `bash "$INSTALL_SCRIPT"`, and cleaned up with `rm -f`. No `--` was present in the original pipe invocation, so no argument adjustment was needed.

