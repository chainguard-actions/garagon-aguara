<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This pattern executes remotely-fetched content without first saving it to disk for inspection, allowing a compromised or man-in-the-middle response to execute arbitrary code on the runner.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:134`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. The `INSTALL_DIR` env var is set from `${{ runner.temp }}/aguara-bin` — a workflow-expression-derived value — and is forwarded to GITHUB_PATH without the required `printf '%s' ... | tr -d '\n\r'` sanitization step. A newline injected into `runner.temp` could allow PATH manipulation.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 98): Replaced `curl ... | bash` with downloading install.sh to a mktemp file, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. github-env-injection (line 100): Added sanitization of INSTALL_DIR before writing to GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.
3. unpinned-uses (line 134): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.

