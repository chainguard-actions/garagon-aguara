<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml fetches a remote script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remotely fetched content without first saving it to a file for inspection, allowing a compromised or man-in-the-middle response to execute arbitrary code on the runner.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:150`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization. `INSTALL_DIR` is set from `${{ runner.temp }}/aguara-bin` — the `runner.temp` value comes from the `runner.*` context, which is workflow-controlled and must be treated as untrusted. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. A newline embedded in the value could inject additional entries into PATH.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 99): Replaced `curl ... | bash` with downloading the install script to a temp file via `mktemp`, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. unpinned-uses (line 150): Pinned `github/codeql-action/upload-sarif@v3` to full commit SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.
3. github-env-injection (line 100): Added sanitization of INSTALL_DIR before writing to GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.

