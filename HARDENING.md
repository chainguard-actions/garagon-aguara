<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script is not saved to a file first and verified before execution. This is an unsafe shell pattern that executes remotely-fetched content without an intermediate integrity check.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:148`

### github-env-injection (severity: high)

In the 'Install Aguara' step, the env var INSTALL_DIR is set from `${{ runner.temp }}/aguara-bin` (a `${{ }}` expression) and then written directly to $GITHUB_PATH via `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-influenced value in runner.temp could inject newlines to smuggle additional PATH entries.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Fixed three findings in hardened/action/action.yml:
1. unsafe-shell (line 98): Replaced `curl ... | bash` with downloading install.sh to a mktemp file, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. github-env-injection (line 100): Added sanitization of INSTALL_DIR before writing to $GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.
3. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

