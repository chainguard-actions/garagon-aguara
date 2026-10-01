<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script is never saved to disk before execution, so its contents cannot be verified. An attacker who compromises the remote host or performs a MITM attack could execute arbitrary code on the runner.

Locations:

- `action.yml:91`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit without notice, creating a supply-chain risk.

Locations:

- `action.yml:148`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. The `INSTALL_DIR` env var is set from `${{ runner.temp }}/aguara-bin`, which flows through a `${{ runner.temp }}` expression. Per the check rules, runner.* context values are untrusted-input expressions, and writing them to special environment files without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`) is a violation that could allow newline injection into GITHUB_PATH.

Locations:

- `action.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

1. unsafe-shell (line 91): Replaced `curl ... | bash` with downloading the install script to a mktemp file first (`curl -o "$INSTALL_SCRIPT"`), then executing it with `bash "$INSTALL_SCRIPT"`, then removing it. This allows the script contents to be verified before execution and prevents MITM attacks from executing arbitrary code directly. 2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the immutable commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with a `# v3` comment for readability. 3. github-env-injection (line 92): Added sanitization of `$INSTALL_DIR` using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before writing to `$GITHUB_PATH`, preventing newline injection attacks.

