<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml downloads a remote shell script and pipes it directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe pattern — if the remote server is compromised or the content is tampered with in transit, arbitrary code executes immediately with no opportunity for inspection.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than a full 40-character commit SHA. A mutable tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

Fixed two security findings in action.yml: (1) unsafe-shell: replaced `curl ... | bash` with a safe two-step pattern — download to a temp file via `mktemp`, then execute with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`; (2) unpinned-uses: pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@dd903d2e4f5405488e5ef1422510ee31c8b32357` with `# v3` comment for readability.

