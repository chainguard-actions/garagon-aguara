<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely-fetched script directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remote content without first saving it to a file for inspection, allowing a compromised or MITM'd response to execute arbitrary code immediately.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit without notice.

Locations:

- `action.yml:138`

### github-env-injection (severity: high)

The 'Install Aguara' step sets `INSTALL_DIR: ${{ runner.temp }}/aguara-bin` in the env: block and then writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without the required sanitization step (`printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`). The `runner.temp` value flows through YAML template substitution before the shell processes it, and writing it unsanitized to $GITHUB_PATH allows newline injection that could add arbitrary entries to the PATH.

Locations:

- `action.yml:80`
- `action.yml:99`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Fixed three security findings in hardened/action/action.yml:
1. unsafe-shell (line 98): Replaced `curl ... | bash` pipe with download-to-tempfile-then-execute pattern. Script is saved via `-o "$INSTALL_SCRIPT"`, executed with `bash "$INSTALL_SCRIPT"`, then cleaned up with `rm -f`.
2. unpinned-uses (line 138): Pinned `github/codeql-action/upload-sarif@v3` to full commit SHA `@ce5e7eeac396d720fe2d802714996c8ce561e311 # v3`.
3. github-env-injection (lines 80/99): Added sanitization of the `INSTALL_DIR` value before writing to `$GITHUB_PATH` using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` to strip newline characters that could inject additional PATH entries.

