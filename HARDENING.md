<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.27.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.27.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh with curl and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file first, check it (for example against a pinned checksum), then run it as a separate step.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

A composite step references an action by a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v4`.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes an env-routed value to $GITHUB_PATH without first stripping newlines: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR is set in the step's env: block from `${{ runner.temp }}/aguara-bin`, not computed inside the run: block, so the check requires `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before the write.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

- unsafe-shell: install.sh is now saved to a temp file with curl -o. The step stops if the file is empty, then runs it with 'bash "$INSTALL_SCRIPT"'. Upstream's 'curl | bash' passed no arguments and didn't use errexit, so nothing changes there. It is not checked against a checksum, because I couldn't fetch the file to compute a trusted one.
- unpinned-uses: github/codeql-action/upload-sarif@v4 is pinned to 915412ff23e8b7659517e607487dbeae018f2934 # v4.
- github-env-injection: INSTALL_DIR now goes through tr -d '\n\r' before it is written to $GITHUB_PATH.
- Extra fix: ACTION_REF was set from github.action_ref. On the mirror that is the mirror's ref, and it picks which install.sh to download from garagon/aguara. I set it to the upstream ref 'v0.27.0' so it can't point at a commit only the mirror has. The install-script-ref override and the check that the ref is a release tag or 40-character SHA are unchanged.

