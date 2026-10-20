<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file first, check its checksum, then run it as a separate command.

Locations:

- `action.yml:75`

### unpinned-uses (severity: high)

A composite step references an action by a version tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:135`

### github-env-injection (severity: high)

The 'Install Aguara' step runs `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR is set in the step's env: block from ${{ runner.temp }}, so it is not a literal computed inside the run: script. The value is written without first running `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.

Locations:

- `action.yml:77`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three findings are fixed in action.yml. I haven't run the action or its tests since changing it.

- unsafe-shell: install.sh is now saved to a temp file before it runs, instead of going straight from curl into bash. If the download is empty the step stops, and it prints the file's sha256 hash in the log. It does not compare that hash to an expected value: the ref can be any release tag or commit, so there is no single known hash to check against. What limits the risk is the action's existing rule that the ref must be a vX.Y.Z tag or a 40-character commit SHA. After that the file runs with `bash "$file"` with no arguments, as before, and is then deleted.
- github-env-injection: INSTALL_DIR has newlines and carriage returns stripped with `printf '%s' | tr -d '\n\r'` before it is written to $GITHUB_PATH.
- unpinned-uses: github/codeql-action/upload-sarif@v3 is now pinned to commit ce5e7eeac396d720fe2d802714996c8ce561e311, with a `# v3` comment.

