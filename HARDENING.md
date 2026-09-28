<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows arbitrary remote code execution if the URL is compromised or the ref is manipulated.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) instead of a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:129`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization. `INSTALL_DIR` is set from `${{ runner.temp }}/aguara-bin` — a `runner.*` context value that flows through YAML template substitution. The write `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` is missing the required `printf '%s' ... | tr -d '\n\r'` sanitization step before the write, allowing newline injection into the PATH.

Locations:

- `action.yml:99`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 98): Replaced `curl ... | bash` pipe with download-then-execute pattern: script is saved to a temp file via `mktemp`, executed with `bash "$INSTALL_SCRIPT"`, then cleaned up with `rm -f`.
2. github-env-injection (line 99): Added sanitization of INSTALL_DIR before writing to GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` to strip newline/carriage-return characters.
3. unpinned-uses (line 129): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

