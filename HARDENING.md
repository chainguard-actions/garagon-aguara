<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is validated against a semver/SHA pattern, piping remote content directly to a shell interpreter without first saving it to a file is an unsafe shell pattern — the script content is never inspected before execution.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag (`@v3`) instead of a pinned 40-character commit SHA. A mutable tag can be silently updated to point to different (potentially malicious) code, creating a supply-chain risk.

Locations:

- `action.yml:155`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a safe download-then-execute pattern: the install script is saved to a mktemp file via `curl -o "$INSTALL_SCRIPT"`, executed with `bash "$INSTALL_SCRIPT"`, then removed. No '--' separator was present in the original pipe form so none was introduced. 2. unpinned-uses (line 155): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with the original tag preserved as a `# v3` comment.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at the 'Install Aguara' step. The INSTALL_DIR value (derived from runner.temp context) was being written directly to $GITHUB_PATH without sanitization. Added a sanitization step: `safe=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')` and then `echo "$safe" >> "$GITHUB_PATH"` to strip any embedded newlines before writing to $GITHUB_PATH, preventing potential PATH injection attacks.

