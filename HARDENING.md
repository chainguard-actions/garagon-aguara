<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh with curl and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file first, optionally check it, then run it separately.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

A composite step references an action by a mutable tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

Fixed both findings in action.yml. The action has not been run since these changes.

- unsafe-shell: The Install Aguara step now saves install.sh to a mktemp file under RUNNER_TEMP and stops if the file is empty. It then runs `bash "$INSTALL_SCRIPT"` and deletes the file. The script gets no arguments, as before, and the existing check that limits the ref to a semver tag or 40-character SHA is unchanged.
- unpinned-uses: Pinned github/codeql-action/upload-sarif to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3).

Possible problem I left alone: install.sh is still downloaded from garagon/aguara using github.action_ref. If the hardened copy is referenced by a SHA that only exists in the fork, the download will fail with a 404. A ref that isn't a semver tag or a SHA falls back to v0.22.1.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Install Aguara' step of action.yml, INSTALL_DIR now has CR/LF removed (printf '%s' | tr -d '\n\r') before it is written to $GITHUB_PATH.

