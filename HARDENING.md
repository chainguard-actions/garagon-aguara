<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step pipes a remotely-fetched script directly to bash without first saving it to disk for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. If the remote URL is compromised or the ref is manipulated, arbitrary code executes immediately on the runner with no opportunity to verify the script's contents.

Locations:

- `action.yml:101`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which is a mutable tag rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit without notice, enabling supply-chain attacks.

Locations:

- `action.yml:131`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 101): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No `--` separator was present in the original pipe form so none was introduced. 2. unpinned-uses (line 131): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311` with a `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (derived from `${{ runner.temp }}/aguara-bin`) is now sanitized with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before being written to $GITHUB_PATH. The sanitized value is stored in `safe_install_dir` and then echoed to $GITHUB_PATH, preventing potential newline-injection attacks.

