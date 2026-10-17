<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from GitHub raw content and pipes it directly to bash without saving to disk first: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Although the ref is validated to be a semver tag or 40-char SHA, piping remote content directly to a shell interpreter is an unsafe pattern.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The composite action step uses `github/codeql-action/upload-sarif@v3`, which references a mutable tag (`@v3`) instead of a pinned 40-character commit SHA. This is vulnerable to supply-chain attacks if the tag is moved to a different commit.

Locations:

- `action.yml:143`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. No '--' was present in the original pipe invocation so none was introduced. 2. unpinned-uses (line 143): Replaced `github/codeql-action/upload-sarif@v3` with the pinned SHA `github/codeql-action/upload-sarif@ce5e7eeac396d720fe2d802714996c8ce561e311 # v3`.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in action.yml at the 'Install Aguara' step. The INSTALL_DIR value (set from ${{ runner.temp }}/aguara-bin) was being written directly to $GITHUB_PATH without sanitization. Added sanitization using `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` and then writing `$safe_install_dir` to $GITHUB_PATH instead. This prevents newline injection attacks where a malicious runner.temp value could inject additional entries into $GITHUB_PATH.

