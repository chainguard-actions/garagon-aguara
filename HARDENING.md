<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml fetches a remote shell script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe shell pattern — if the remote server or the ref is compromised, arbitrary code executes on the runner. The script should be downloaded to a file first, its checksum verified, and then executed separately.

Locations:

- `action.yml:88`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character SHA commit hash. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:148`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. `INSTALL_DIR` is set in the `env:` block from `${{ runner.temp }}/aguara-bin`, which flows through YAML template substitution before the shell sees it. Writing this value to a special GitHub environment file without first applying `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` allows a newline-injection attack that could add arbitrary entries to `$GITHUB_PATH`.

Locations:

- `action.yml:89`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Three fixes applied to hardened/action/action.yml: (1) unsafe-shell: replaced `curl ... | bash` with downloading the install script to a mktemp file via `-o "$INSTALL_SCRIPT"`, executing it with `bash "$INSTALL_SCRIPT"`, then removing it; (2) unpinned-uses: pinned `github/codeql-action/upload-sarif@v3` to full SHA `9f759ee644a3e7c15c1390abf49868036c00067b # v3`; (3) github-env-injection: sanitized `$INSTALL_DIR` with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before writing to `$GITHUB_PATH`.

