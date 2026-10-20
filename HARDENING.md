<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step pipes remote content straight into a shell: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download install.sh to a file first, then run it as a separate command.

Locations:

- `action.yml:99`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without first running `printf '%s' ... | tr -d '\n\r'`. INSTALL_DIR comes from the step's env block (`${{ runner.temp }}/aguara-bin`), not from a literal computed inside the run script.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

A composite step uses a mutable tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

install.sh is now downloaded to a mktemp file with curl -o, checked to be non-empty, run with bash, then removed. It still runs without errexit and without arguments, as upstream did. INSTALL_DIR is passed through printf '%s' | tr -d '\n\r' before being written to GITHUB_PATH. github/codeql-action/upload-sarif@v3 is now pinned to ce5e7eeac396d720fe2d802714996c8ce561e311 # v3.

### Iteration 2

**Fixes applied:** unsafe-shell, github-env-injection

**Notes:**

install.sh is now downloaded to a mktemp file, checked to be non-empty, run with 'bash "$file"' (no args, matching upstream's pipe), then removed. INSTALL_DIR has newlines stripped via printf|tr before it is written to GITHUB_PATH. The ref validation (semver tag or 40-char SHA) is unchanged.

