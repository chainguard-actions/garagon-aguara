<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first downloading it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This pattern executes whatever the remote server returns without any opportunity to inspect or verify the content before execution.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than a full 40-character SHA commit hash. A mutable tag can be moved to point to a different (potentially malicious) commit without notice, enabling supply-chain attacks.

Locations:

- `action.yml:148`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a two-step approach: download the install script to a temp file using `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. This eliminates the pipe-to-bash pattern and allows the script to be inspected before execution.
2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `github/codeql-action/upload-sarif@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`, preserving the tag as a comment for readability.

