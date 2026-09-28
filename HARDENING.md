<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe shell pattern — the script content is never inspected before execution.

Locations:

- `action.yml:94`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved to a different commit.

Locations:

- `action.yml:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 94): Replaced `curl ... | bash` with a safe two-step pattern: download install.sh to a mktemp file, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This allows the script to be inspected before execution and eliminates the pipe-to-bash anti-pattern. 2. unpinned-uses (line 130): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with `# v3` comment for readability.

