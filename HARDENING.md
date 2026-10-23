<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is checked against a semver/SHA pattern, the remote script runs without first being saved to a file and checked. Download it to a file, then run it as a separate step.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The composite step uses a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the env-routed value INSTALL_DIR (set from `${{ runner.temp }}/aguara-bin`) to $GITHUB_PATH with `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` and does not sanitize it first with `printf '%s' ... | tr -d '\n\r'`. The value comes from outside this run block, so it needs the sanitization step before the write.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

Install step: install.sh is now saved to a temp file under RUNNER_TEMP, the step stops if the file is empty, then it runs as `bash "$INSTALL_SCRIPT"`. Upstream piped it into bash with no arguments, so there were none to carry over. It still runs in the same step because the script needs that step's env vars (VERSION, INSTALL_DIR, GITHUB_TOKEN). The ref check stays as it was. INSTALL_DIR now has newlines stripped with printf/tr before it is written to $GITHUB_PATH. github/codeql-action/upload-sarif is pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (v3).

