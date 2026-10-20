<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote script and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script should be saved to a file first (and ideally have its checksum checked) and then run as a separate command.

Locations:

- `action.yml:101`

### unpinned-uses (severity: high)

A composite step uses a mutable tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:165`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the value of the env var INSTALL_DIR to $GITHUB_PATH without first sanitizing it with `printf '%s' ... | tr -d '\n\r'`: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR is set in the step's env: block from ${{ runner.temp }}. It is not a literal computed inside the run: block, so the check requires sanitization.

Locations:

- `action.yml:103`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

- unsafe-shell: install.sh is now saved to a temporary file (mktemp) with curl -o. The step stops with an error if the file is empty, otherwise runs it with 'bash "$INSTALL_SCRIPT"' and then deletes it. There is no checksum check, because no known hash is available to check against. Upstream piped into bash with no arguments, so nothing else changed.
- unpinned-uses: github/codeql-action/upload-sarif@v3 is now pinned to ce5e7eeac396d720fe2d802714996c8ce561e311 (looked up with lookup_action_sha) and keeps a '# v3' comment.
- github-env-injection: INSTALL_DIR has newlines and carriage returns stripped with printf '%s' | tr -d '\n\r' and is saved to a separate variable before being written to $GITHUB_PATH.

Nothing was run to test these changes.

