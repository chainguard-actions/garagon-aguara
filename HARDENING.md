<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote script and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file first (and ideally check its checksum), then run it as a separate command.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

A composite step references an action by a version tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`. Pin it to a 40-character commit SHA.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR comes from the env: block (`${{ runner.temp }}/aguara-bin`), not from a value computed in the script. It is written to GITHUB_PATH without first running `printf '%s' ... | tr -d '\n\r'` to strip newlines.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

- unsafe-shell: install.sh is now downloaded to a temp file made with mktemp and then run with 'bash "$INSTALL_SCRIPT"'. It keeps the same environment variables (VERSION, INSTALL_DIR, GITHUB_TOKEN) and is deleted afterwards. No checksum check was added, because no published hash is available. The ref is still limited to a semver tag or a 40-character SHA, as upstream already did.
- unpinned-uses: github/codeql-action/upload-sarif@v3 is now pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 with a '# v3' comment. I got that SHA from lookup_action_sha.
- github-env-injection: INSTALL_DIR now has newlines stripped (printf '%s' | tr -d '\n\r') before it is written to GITHUB_PATH.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned github/codeql-action/upload-sarif@v3 to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3 in action.yml.

