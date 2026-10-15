<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first downloading and verifying it: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated against a semver/SHA pattern, piping remote content directly to a shell interpreter is an unsafe pattern that bypasses any opportunity to inspect the script before execution.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which references a mutable version tag rather than a pinned 40-character commit SHA. If the tag is moved (intentionally or via a supply-chain compromise), the action will silently execute different code.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up the temp file afterwards. No '--' was present in the original pipe form so none was needed in the converted form. 2. unpinned-uses (line 168): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b`, preserving the tag as a `# v3` comment for readability.

