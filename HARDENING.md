<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote script and pipes it directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remote content without first saving it to a file for inspection, which is an unsafe shell pattern that can lead to arbitrary code execution if the remote resource is compromised or tampered with.

Locations:

- `action.yml:76`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character commit SHA. A mutable tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:116`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 76): Replaced `curl ... | bash` with a safe two-step approach: download the install script to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No arguments were passed to the script so no '--' handling was needed. 2. unpinned-uses (line 116): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311`, preserving the original tag as a `# v3` comment for readability.

