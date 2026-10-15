<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote script and pipes it directly to bash without saving it to a file first: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe-shell pattern — if the remote URL is compromised or the ref is manipulated, arbitrary code executes immediately in the runner.

Locations:

- `action.yml:90`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than a full 40-character SHA commit hash. If the tag is moved to a different commit, the action will silently execute different code, enabling supply-chain attacks.

Locations:

- `action.yml:131`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 90): Replaced `curl ... | bash` with a safe pattern: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. No '--' was present in the original pipe form so none needed to be dropped. 2. unpinned-uses (line 131): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `github/codeql-action/upload-sarif@9f759ee644a3e7c15c1390abf49868036c00067b # v3`.

