<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote shell script and pipes it directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows arbitrary remote code execution if the remote URL is compromised or redirected.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a full 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved to point to a different (potentially malicious) commit.

Locations:

- `action.yml:143`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a safe two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. 2. unpinned-uses (line 143): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311` with a `# v3` comment preserved for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at the 'Install Aguara' step. The INSTALL_DIR value (derived from `${{ runner.temp }}/aguara-bin`) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step using `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` before the write, then writing `$safe_install_dir` to $GITHUB_PATH instead of the raw `$INSTALL_DIR`. This prevents a malicious runner.temp value containing newlines from injecting additional entries into $GITHUB_PATH.

