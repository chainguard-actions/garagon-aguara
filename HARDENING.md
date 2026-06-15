<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.27.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **garagon--aguara/v0.27.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first saving it to a file for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows arbitrary remote code execution if the remote URL is compromised or the ref is manipulated.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step uses `github/codeql-action/upload-sarif@v4`, which is a mutable tag reference. If the tag is moved to a different commit, the action will silently execute different code. It should be pinned to a full 40-character commit SHA (e.g., `github/codeql-action/upload-sarif@<sha> # v4`).

Locations:

- `action.yml:167`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file using `curl ... -o "$INSTALL_SCRIPT"`, then execute it with `bash "$INSTALL_SCRIPT"`, and clean up with `rm -f "$INSTALL_SCRIPT"`. This eliminates the risk of piping untrusted remote content directly into bash. 2. unpinned-uses (line 167): Pinned `github/codeql-action/upload-sarif@v4` to the full commit SHA `github/codeql-action/upload-sarif@8aad20d150bbac5944a9f9d289da16a4b0d87c1e # v4` to prevent silent execution of different code if the mutable tag is moved.

