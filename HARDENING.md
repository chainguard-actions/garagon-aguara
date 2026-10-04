<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remote content without first saving it to a file for inspection or independent verification. An attacker who can influence the fetched URL or intercept the connection could execute arbitrary code on the runner.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than an immutable 40-character commit SHA. If the tag is moved (e.g., by a compromised upstream repository), the action will silently execute different code on the next run.

Locations:

- `action.yml:149`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 100): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file using `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up the temp file afterward. 2. unpinned-uses (line 149): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

