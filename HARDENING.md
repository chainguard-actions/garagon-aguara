<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from GitHub and pipes it directly to bash via `curl ... | bash`. This executes remote content without first saving it to a file for inspection, allowing a compromised or tampered install.sh to execute arbitrary code immediately. Pattern: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the env var `$INSTALL_DIR` to `$GITHUB_PATH` without applying the required sanitization (`printf '%s' ... | tr -d '\n\r'`). `INSTALL_DIR` is set from `${{ runner.temp }}/aguara-bin`, which flows through YAML template substitution before the shell sees it. Although `runner.temp` is runner-controlled rather than directly attacker-controlled, the check rules require sanitization for all `${{ }}` expressions (including `runner.*`) before writing to special environment files. The unsanitized write is: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 98): Replaced `curl ... | bash` with downloading install.sh to a mktemp file, executing it with `bash "$INSTALL_SCRIPT"`, then removing the temp file.
2. unpinned-uses (line 168): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.
3. github-env-injection (line 100): Added sanitization of INSTALL_DIR via `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before writing to $GITHUB_PATH.

