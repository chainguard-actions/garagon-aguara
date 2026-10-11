<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script is never saved to disk for inspection before execution. An attacker who can influence the fetched content (e.g., via a compromised CDN, MITM, or by controlling the ref) can execute arbitrary code on the runner.

Locations:

- `action.yml:92`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' references `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`@v3`) rather than an immutable 40-character SHA commit hash. A tag can be moved to point to a different (potentially malicious) commit at any time, enabling a supply-chain attack.

Locations:

- `action.yml:143`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 92): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No `--` was dropped since the original piped form passed no arguments to the script. 2. unpinned-uses (line 143): Pinned `github/codeql-action/upload-sarif@v3` to the full immutable SHA `9f759ee644a3e7c15c1390abf49868036c00067b`, preserving the tag as a `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (derived from runner.temp context) was being written directly to $GITHUB_PATH without sanitization. Added sanitization using `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` and then writing `$safe_install_dir` to $GITHUB_PATH instead of the raw $INSTALL_DIR value.

