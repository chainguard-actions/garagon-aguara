<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely fetched script directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe shell pattern — remote content is executed immediately without inspection or integrity verification of the shell script itself (separate from the binary checksum verification done inside install.sh).

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character SHA commit hash. If the tag is moved (e.g. by a supply-chain compromise), the action would silently execute different code.

Locations:

- `action.yml:150`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a safe two-step pattern: download install.sh to a temp file using `mktemp` and curl's `-o` flag, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. 2. unpinned-uses (line 150): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `github/codeql-action/upload-sarif@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml (line 84). The INSTALL_DIR value (from runner.temp context) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` to strip newline and carriage return characters before writing to $GITHUB_PATH, preventing potential environment file injection attacks.

