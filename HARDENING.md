<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first downloading it to a file: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This means the script content is never inspected before execution, and any compromise of the remote URL or a network interception could result in arbitrary code execution on the runner.

Locations:

- `action.yml:90`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 90): Replaced `curl ... | bash` with a two-step approach: download the install script to a mktemp file with `curl ... -o "$INSTALL_SCRIPT"`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up with `rm -f`. This prevents arbitrary code execution from network interception or remote URL compromise. 2. unpinned-uses (line 130): Pinned `github/codeql-action/upload-sarif@v3` to the full immutable commit SHA `@dd903d2e4f5405488e5ef1422510ee31c8b32357` with a `# v3` comment for readability, preventing supply-chain attacks via mutable tag movement.

