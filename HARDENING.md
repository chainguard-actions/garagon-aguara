<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml downloads install.sh from a remote URL and pipes it directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Although INSTALL_REF is validated to be a semver tag or 40-char SHA, the script content is never downloaded to a file for inspection before execution — it is piped directly into the shell interpreter. This is the classic unsafe curl-pipe-to-shell pattern.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag (`v3`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, creating a supply-chain risk.

Locations:

- `action.yml:142`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a safe download-then-execute pattern: script is downloaded to a mktemp file with `curl -o`, executed with `bash "$INSTALL_SCRIPT"`, then removed. No `--` separator was present in the original so none was dropped. 2. unpinned-uses (line 142): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with a `# v3` comment preserved for readability.

