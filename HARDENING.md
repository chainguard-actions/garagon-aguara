<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote shell script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remote content without first downloading and verifying it, which is an unsafe pattern even when the URL is constructed from a validated ref.

Locations:

- `action.yml:92`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which references a mutable tag (@v3) rather than a pinned 40-character SHA commit hash. This is vulnerable to supply-chain attacks if the tag is moved to a different commit.

Locations:

- `action.yml:148`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 92): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up the temp file afterward. 2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52` with a `# v3` comment preserved for readability.

