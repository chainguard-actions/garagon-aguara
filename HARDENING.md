<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 2 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh with curl and pipes it straight into bash without saving it to disk or checking it first: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Fix: download the script to a file, verify it (for example against a checksum), then run it as a separate step.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

A composite step references an action by a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`. Fix: pin it to a commit SHA.

Locations:

- `action.yml:169`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

unsafe-shell: The 'Install Aguara' step no longer pipes a remote install.sh into bash. It now runs the install.sh that ships with the action ($GITHUB_ACTION_PATH/install.sh), which comes from the same commit as the action. That script still checks release archives against checksums.txt. It runs with plain 'bash' and no -e, as upstream did. The ref validation is kept. If install-script-ref is set, the step now prints a notice and uses the bundled script, so that self-testing input no longer fetches a remote script. unpinned-uses: github/codeql-action/upload-sarif@v3 is now pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3.

### Iteration 2

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

- Pinned github/codeql-action/upload-sarif to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3). I got this SHA from lookup_action_sha.
- The Install Aguara step now strips newlines from INSTALL_DIR before writing it to $GITHUB_PATH: printf '%s' | tr -d '\n\r'.
- Repaired the jq command in the JSON branch of the scan step. An earlier edit had overwritten it with the pin text ('upload-sarif@<sha> # v3'), which broke the line's quoting. I restored it as jq '.findings | length // 0'. The original command was lost, so I rebuilt it from the scan JSON output, which has a top-level 'findings' key. This is my reconstruction, not upstream's exact text.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

In action.yml's 'Install Aguara' step, replaced `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r' >> "$GITHUB_PATH"` followed by `echo >> "$GITHUB_PATH"` so the line still ends with a newline.

