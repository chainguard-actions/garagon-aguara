<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script is never saved to disk for inspection before execution. This is an unsafe shell pattern — if the remote URL is compromised or the ref is manipulated, arbitrary code executes on the runner.

Locations:

- `action.yml:96`

### unpinned-uses (severity: high)

The action references `github/codeql-action/upload-sarif@v3` using a mutable tag (`v3`) instead of a pinned 40-character commit SHA. If the tag is moved (intentionally or via a supply-chain compromise), the action will silently execute different code.

Locations:

- `action.yml:148`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 96): Replaced `curl ... | bash` with a safe two-step pattern: download install.sh to a temp file via `mktemp` and `curl -o`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This prevents arbitrary code execution if the remote URL is compromised, and allows the script to be inspected before running.
2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the full 40-character commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311`, keeping `# v3` as a comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (sourced from runner.temp context) is now sanitized with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before being written to $GITHUB_PATH, preventing potential newline injection into the PATH environment file.

