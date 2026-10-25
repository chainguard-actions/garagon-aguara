<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh and pipes it straight to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script runs without first being saved to a file and checked.

Locations:

- `action.yml:98`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without the `printf '%s' ... | tr -d '\n\r'` cleanup step. INSTALL_DIR comes from the step's env: block (`${{ runner.temp }}/aguara-bin`). It is not a literal computed inside the run block, so it has to be cleaned before it is written to GITHUB_PATH.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

The composite action step uses a mutable tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

I fixed all three findings in action.yml. Nothing was run to test the changes.

1. unsafe-shell: install.sh is no longer piped straight into bash. The step now saves it to a temp file, stops with an error if the file is empty, runs it with `bash "$INSTALL_SCRIPT"` and then deletes it. The empty-file check only catches a blank download; it does not verify the script's contents.
2. github-env-injection: before writing INSTALL_DIR to GITHUB_PATH, the step now strips newlines and carriage returns with `printf '%s' | tr -d '\n\r'`.
3. unpinned-uses: `github/codeql-action/upload-sarif` is now pinned to commit 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (the current v3), with `# v3` kept as a comment.

Unchanged and worth knowing: when this hardened copy runs, the ref the caller pins to (`github.action_ref`) will be the hardened copy's ref, not an aguara release tag. If that ref isn't a vX.Y.Z tag or a 40-character SHA, the step prints a warning and fetches install.sh from v0.22.1, which is the upstream default.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned github/codeql-action/upload-sarif@v3 to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3 in action.yml. The other 'uses:' matches are only text inside input descriptions.

