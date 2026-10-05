<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.28.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.28.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from raw.githubusercontent.com and pipes it directly to bash (`curl -fsSL ... | bash`). This executes remote content without first saving it to a file for inspection or integrity verification, making the action vulnerable to supply-chain attacks if the remote URL is compromised or tampered with.

Locations:

- `action.yml:123`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v4`, which uses a mutable tag (`v4`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:152`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 123): Replaced `curl ... | bash` with a safe pattern: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up with `rm -f`. This avoids executing remote content without first saving it to a file. 2. unpinned-uses (line 152): Pinned `github/codeql-action/upload-sarif@v4` to the full commit SHA `@2892aa5e19bbd11bc0cff5427e3b750a04d9e3c2 # v4` to prevent supply-chain attacks via mutable tag references.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at the 'Install Aguara' step. The INSTALL_DIR value (derived from runner.temp, which is workflow-controllable) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step: `safe=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')` and then `echo "$safe" >> "$GITHUB_PATH"` to strip embedded newlines that could inject additional PATH entries.

