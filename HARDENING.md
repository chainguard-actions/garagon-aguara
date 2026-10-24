<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from raw.githubusercontent.com and pipes it straight into bash without saving it first: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Save the script to a file, check it (for example with a checksum), then run it as a separate command.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

A composite step pins an action by a mutable tag instead of a commit SHA: `uses: github/codeql-action/upload-sarif@v3`. Pin it to the full 40-character commit SHA.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR comes from an env: expression (`${{ runner.temp }}/aguara-bin`), not from a value computed inside the script, and nothing strips newlines before the write. Apply `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before writing it to GITHUB_PATH.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three fixes are in action.yml. Nothing was run or tested. (1) unsafe-shell: install.sh is no longer piped into bash. It is saved to a temp file first, checked, then run with `bash "$INSTALL_SCRIPT"` and deleted. The check only confirms the file isn't empty and starts with a `#!` line; it also prints the file's SHA-256 to the log. It is not a real checksum match: the ref can be a version tag, a commit SHA or a user-supplied input, so there is no single known hash to compare against. The script still runs with no arguments, the same as upstream. (2) unpinned-uses: github/codeql-action/upload-sarif is now pinned to commit 4bfa242aa49c5f7c6770b98670d354a7dfac05f8, which is what the v3 tag pointed to when looked up; the `# v3` comment is kept. (3) github-env-injection: INSTALL_DIR has newlines and carriage returns removed with `printf '%s' | tr -d '\n\r'` before it is written to GITHUB_PATH.

