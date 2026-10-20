<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite step points to a version tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:169`

### unsafe-shell (severity: high)

The Install Aguara step downloads a remote script and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file, check it, then run it.

Locations:

- `action.yml:99`

### github-env-injection (severity: high)

The Install Aguara step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without first running the required `printf '%s' ... | tr -d '\n\r'` sanitization. INSTALL_DIR comes from the step's env: block (`${{ runner.temp }}/aguara-bin`), not from a literal computed in the same run: script.

Locations:

- `action.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, unsafe-shell, github-env-injection

**Notes:**

Pinned github/codeql-action/upload-sarif to ce5e7eeac396d720fe2d802714996c8ce561e311 (v3). install.sh is now saved to a mktemp file with curl -o. The step then checks the file is not empty and starts with a shebang, runs it with bash and deletes it. The env vars install.sh needs are unchanged. INSTALL_DIR now has newlines stripped (printf | tr -d '\n\r') before it is written to GITHUB_PATH.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned github/codeql-action/upload-sarif@v3 to ce5e7eeac396d720fe2d802714996c8ce561e311 (# v3) in action.yml.

