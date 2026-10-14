<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash without first saving it to a file: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated to be a semver tag or 40-char SHA, the script is never inspected before execution. If the remote host or the content at that ref is compromised, arbitrary code runs in the workflow.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

The composite action step uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable version tag (`@v3`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:155`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 100): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f`. This ensures the script can be inspected before execution and prevents arbitrary code from running if the remote content is compromised mid-stream. No '--' separator was present in the original pipe form, so none was introduced. 2. unpinned-uses (line 155): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b`, preserving the original tag as a `# v3` comment for readability.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml (line 97). Added sanitization of the INSTALL_DIR value before writing to $GITHUB_PATH: replaced `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` with `safe_install_dir="$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')"` followed by `echo "$safe_install_dir" >> "$GITHUB_PATH"`. This strips any newline or carriage return characters that could be used to inject arbitrary entries into $GITHUB_PATH.

