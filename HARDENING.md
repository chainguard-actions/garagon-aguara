<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable version tag (`@v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, enabling a supply-chain attack.

Locations:

- `action.yml:163`

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to `bash` via `curl -fsSL ... | bash`. This pattern executes remotely-fetched content without first saving it to disk for inspection or integrity verification. If the remote URL is compromised or the network connection is intercepted, arbitrary code will be executed on the runner.

Locations:

- `action.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (action.yml line 96): Replaced `curl ... | bash` pipe pattern with a safe two-step approach: download install.sh to a temp file via `mktemp` and `curl -o`, then execute with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No `--` separator was present in the original, so no argument-shifting issue. 2. unpinned-uses (action.yml line 163): Pinned `github/codeql-action/upload-sarif@v3` to the full 40-character commit SHA `1190a975f95ce23525efb6a3fc21ea29567c1b52` with a `# v3` comment preserved for readability.

