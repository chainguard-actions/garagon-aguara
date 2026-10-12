<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote shell script and pipes it directly to bash without first saving it to a file: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This means any compromise of the remote host or a MITM attack could execute arbitrary code on the runner.

Locations:

- `action.yml:90`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:143`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the env var `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization. `INSTALL_DIR` is set from the workflow-controllable context value `${{ runner.temp }}/aguara-bin` in the env block. The write `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` is not preceded by the required sanitization step (`printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`), allowing a newline-injection attack that could add arbitrary entries to the runner's PATH.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 90): Replaced `curl ... | bash` with downloading the install script to a temp file via `mktemp`, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. github-env-injection (line 91): Added sanitization of INSTALL_DIR before writing to $GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.
3. unpinned-uses (line 143): Pinned `github/codeql-action/upload-sarif@v3` to full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

