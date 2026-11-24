<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.29.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.29.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh with curl and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file first, then run it as a separate step (ideally after verifying a checksum).

Locations:

- `action.yml:123`

### unpinned-uses (severity: high)

A composite step references an action by a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v4`.

Locations:

- `action.yml:195`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR comes from the step's env: block (`${{ runner.temp }}/aguara-bin`), not from a literal set inside the same run: script, and it is written without the required `printf '%s' ... | tr -d '\n\r'` sanitization.

Locations:

- `action.yml:126`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Changed the 'Install Aguara' step so it downloads install.sh to a temp file with curl and then runs that file with bash, instead of piping curl straight into bash. Pinned github/codeql-action/upload-sarif to 915412ff23e8b7659517e607487dbeae018f2934 (# v4). INSTALL_DIR now has newlines and carriage returns stripped before it is written to GITHUB_PATH. One extra change: ACTION_REF was github.action_ref, which on the mirror is a mirror commit. The step fetches install.sh from garagon/aguara at that ref, so it would have failed. I set it to the literal upstream ref 'v0.29.0'. No checksum check was added for the downloaded install.sh. The finding suggested one, but upstream publishes no checksum for that file to check against. Nothing was run or tested.

