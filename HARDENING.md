<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **garagon--aguara/v0.22.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash (`curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`). The script is not saved to a file and verified before execution. This allows arbitrary code execution if the remote URL is compromised or the ref is tampered with.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which uses a mutable tag (`v3`) instead of a pinned 40-character SHA commit hash. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks.

Locations:

- `action.yml:166`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` where INSTALL_DIR is set from `${{ runner.temp }}/aguara-bin`. The `runner.*` context is workflow-controllable and the value is written to GITHUB_PATH without the required sanitization step (`printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`). A newline in the value could inject arbitrary entries into GITHUB_PATH.

Locations:

- `action.yml:99`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Fixed three high-severity findings in action.yml: (1) unsafe-shell: replaced `curl ... | bash` with downloading install.sh to a mktemp file first, then executing with `bash`, then removing the temp file; (2) unpinned-uses: pinned `github/codeql-action/upload-sarif@v3` to full SHA `dd903d2e4f5405488e5ef1422510ee31c8b32357` with `# v3` comment; (3) github-env-injection: sanitized INSTALL_DIR with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before writing to $GITHUB_PATH.

