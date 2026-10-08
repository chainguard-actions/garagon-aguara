<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step pipes a remotely fetched script directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows arbitrary remote code execution if the URL is compromised or the content is tampered with in transit.

Locations:

- `action.yml:88`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) instead of a pinned 40-character commit SHA. If the tag is moved or the repository is compromised, the action could execute arbitrary code.

Locations:

- `action.yml:131`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. `INSTALL_DIR` is set from the expression `${{ runner.temp }}/aguara-bin` in the env block. Per the check rules, `runner.*` expressions are untrusted inputs that flow through YAML template substitution before the shell sees them. Writing this value to a special environment file without the required sanitization step (`printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`) is a violation.

Locations:

- `action.yml:89`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 88): Replaced `curl ... | bash` with downloading the install script to a temp file via `mktemp`, then executing `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. unpinned-uses (line 131): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@9f759ee644a3e7c15c1390abf49868036c00067b # v3`.
3. github-env-injection (line 89): Added sanitization of INSTALL_DIR before writing to $GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` stored in `safe_install_dir`, which is then written to $GITHUB_PATH.

