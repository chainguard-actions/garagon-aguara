<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a remote URL and pipes it directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the INSTALL_REF value is validated against a semver or SHA pattern before use, piping remote content directly to a shell interpreter is an unsafe pattern — the script is downloaded and executed in a single pipeline without any opportunity to inspect or verify the content before execution.

Locations:

- `action.yml:101`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable tag (`v3`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, making this a supply-chain risk.

Locations:

- `action.yml:152`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 101): Replaced `curl ... | bash` with a safe download-then-execute pattern: script is saved to a mktemp file with `curl -o`, then executed with `bash "$INSTALL_SCRIPT"`, then removed. No '--' was present in the original pipe invocation so none was introduced. 2. unpinned-uses (line 152): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@9f759ee644a3e7c15c1390abf49868036c00067b # v3`.

