<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote script and pipes it directly to bash without first saving it to disk: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is validated against a semver/SHA pattern, the script is executed immediately from the network without any integrity verification (e.g. checksum or sigstore verification), violating the safe pattern of download-then-execute.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag (`@v3`) rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:130`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 97): Replaced `curl ... | bash` with a safe download-then-execute pattern: the install script is saved to a temp file via `mktemp`, downloaded with `curl -o`, executed with `bash`, then removed. No '--' was present in the original pipe form so none was added. 2. unpinned-uses (line 130): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311`, preserving the tag as a `# v3` comment for readability.

