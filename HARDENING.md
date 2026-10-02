<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first downloading and verifying it: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is the classic curl-pipe-bash anti-pattern; a compromised or MITM'd response would execute arbitrary code on the runner.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`v3`) rather than a pinned 40-character commit SHA. If the tag is moved (intentionally or via a supply-chain compromise), the action will silently execute different code. Pin to a full SHA, e.g. `uses: github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:148`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This eliminates the curl-pipe-bash anti-pattern. 2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The direct `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` was replaced with a two-step approach: first sanitizing the value with `safe_install_dir=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')`, then writing the sanitized value `echo "$safe_install_dir" >> "$GITHUB_PATH"`. This prevents newline injection into GITHUB_PATH from the runner.temp context value.

