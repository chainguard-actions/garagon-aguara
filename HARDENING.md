<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely fetched script directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remote content without first saving it to a file for inspection, allowing a compromised or tampered remote resource to execute arbitrary code in the runner.

Locations:

- `action.yml:91`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses a mutable tag reference `uses: github/codeql-action/upload-sarif@v3` instead of a pinned 40-character SHA commit hash. A mutable tag can be silently updated to point to different (potentially malicious) code, creating a supply-chain risk.

Locations:

- `action.yml:131`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 91): Replaced `curl ... | bash` with a safe two-step pattern: download install.sh to a temp file via `curl -o "$INSTALL_SCRIPT"`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up with `rm -f`. No `--` was present in the original pipe form so none needed to be dropped. 2. unpinned-uses (line 131): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step (action.yml line 80). Added sanitization of the INSTALL_DIR value before writing to $GITHUB_PATH: replaced `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` with `safe_install_dir=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')` followed by `echo "$safe_install_dir" >> "$GITHUB_PATH"`. This strips any embedded newlines or carriage returns that could be used to inject additional entries into GITHUB_PATH.

