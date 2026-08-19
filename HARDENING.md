<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a mutable URL (the `main` branch of the repository) and pipes it directly to bash without first downloading it to a file: `curl -fsSL https://raw.githubusercontent.com/garagon/aguara/main/install.sh | bash`. If the remote content is tampered with or the branch is compromised, arbitrary code will execute on the runner.

Locations:

- `action.yml:57`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which is a mutable tag reference rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:107`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 57): Replaced `curl -fsSL ... | bash` with a safe two-step pattern: download install.sh to a mktemp file, execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. 2. unpinned-uses (line 107): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `f3712979fa5f215279b101dd0a2e3bdfb4353324` with a `# v3` comment preserved for readability.

### Iteration 2

**Fixes applied:** script-injection, unpinned-uses, missing-permissions, github-env-injection

**Notes:**

Fixed all four findings: (1) script-injection in release.yml by moving github.ref_name into env vars REF_NAME in both affected steps; (2) pinned all unpinned action uses to full commit SHAs across ci.yml, release.yml, and test-action.yml; (3) added 'permissions: contents: read' to ci.yml; (4) sanitized INSTALL_DIR before writing to GITHUB_PATH in action.yml using printf+tr to strip newlines.

