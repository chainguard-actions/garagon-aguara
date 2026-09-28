<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step pipes remote content directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated against a semver/SHA pattern, piping a remote script directly to bash is an unsafe-shell pattern — the script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `action.yml:92`

### unpinned-uses (severity: high)

The 'Upload SARIF to GitHub Code Scanning' step references `github/codeql-action/upload-sarif@v3`, which uses a mutable version tag (`@v3`) instead of a pinned 40-character commit SHA. A supply-chain attacker could move the tag to point to malicious code. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:148`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the env var `$INSTALL_DIR` to `$GITHUB_PATH` without sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. `INSTALL_DIR` is set from `${{ runner.temp }}/aguara-bin` — a `runner.*` context value that flows through YAML template substitution and is workflow-controllable. The required sanitization step (`safe=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')`) is missing before the write to the special environment file.

Locations:

- `action.yml:93`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

1. unsafe-shell (line 92): Replaced `curl ... | bash` with download-then-execute pattern: script is saved to a mktemp file, executed with `bash "$INSTALL_SCRIPT"`, then removed. 2. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to full SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3`. 3. github-env-injection (line 93): Added `safe=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')` sanitization step before writing to `$GITHUB_PATH`.

