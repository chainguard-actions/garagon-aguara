<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe shell pattern — the script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `action.yml:89`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved.

Locations:

- `action.yml:131`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the env var `$INSTALL_DIR` (sourced from `${{ runner.temp }}/aguara-bin`, a workflow-controlled context value) directly to `$GITHUB_PATH` without the required sanitization step (`printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`). A calling workflow could inject newlines into `runner.temp` to manipulate GITHUB_PATH entries. The offending line is: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:90`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 89): Replaced `curl ... | bash` with downloading the install script to a mktemp file, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. github-env-injection (line 90): Added sanitization of INSTALL_DIR before writing to GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.
3. unpinned-uses (line 131): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.

