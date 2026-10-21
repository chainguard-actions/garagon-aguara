<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh and pipes it straight into bash without saving it first: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file, then run it as a separate step.

Locations:

- `action.yml:98`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without the required sanitization (`printf '%s' ... | tr -d '\n\r'`). INSTALL_DIR comes from the step's env: block (`${{ runner.temp }}/aguara-bin`). It is not a literal computed inside the run: block.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

A composite step references an action by a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

unsafe-shell: install.sh is now downloaded to a mktemp file under RUNNER_TEMP. The step checks the file isn't empty, runs it with `bash "$file"` (no extra arguments, matching the old pipe), then deletes it. The step's env (VERSION, INSTALL_DIR, GITHUB_TOKEN) is still inherited. github-env-injection: INSTALL_DIR has newlines stripped with printf | tr -d '\n\r' before it is written to GITHUB_PATH. unpinned-uses: github/codeql-action/upload-sarif is pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3. Not run or tested.

