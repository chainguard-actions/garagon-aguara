<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash without first saving it to a file for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This is an unsafe shell pattern — if the remote content is tampered with or the URL is compromised, arbitrary code executes immediately on the runner.

Locations:

- `action.yml:115`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. A mutable tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:155`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 115): Replaced `curl ... | bash` with a two-step approach: download install.sh to a mktemp file with `-o "$INSTALL_SCRIPT"`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No '--' separator was present in the original pipe form so none needed to be dropped. 2. unpinned-uses (line 155): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at the 'Install Aguara' step. The INSTALL_DIR value (derived from runner.temp) was being written directly to $GITHUB_PATH without sanitization. Added sanitization using `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` before writing to $GITHUB_PATH, preventing potential newline injection attacks.

