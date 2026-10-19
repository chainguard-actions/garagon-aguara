<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash without first saving it to a file for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This pattern executes remotely fetched content without any opportunity to verify it before execution.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. The `INSTALL_DIR` env var is set from `${{ runner.temp }}/aguara-bin` — a `runner.*` context value that is workflow-controllable and must be treated as untrusted. No `printf '%s' ... | tr -d '\n\r'` sanitization step is applied before the write, allowing a newline-injection attack to add arbitrary entries to the PATH.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Fixed all three findings in hardened/action/action.yml:
1. unsafe-shell (line 99): Replaced `curl ... | bash` pipe with downloading install.sh to a mktemp file, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. unpinned-uses (line 168): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `ce5e7eeac396d720fe2d802714996c8ce561e311` with `# v3` comment.
3. github-env-injection (line 100): Sanitized `$INSTALL_DIR` using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before writing to `$GITHUB_PATH`.

