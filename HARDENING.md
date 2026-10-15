<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash (`curl ... | bash`). This executes remote content without first saving it to a file for inspection, creating a supply-chain risk if the remote URL is compromised. The script should be downloaded to a temporary file, its integrity verified (e.g., via checksum), and then executed separately.

Locations:

- `action.yml:102`

### unpinned-uses (severity: high)

The step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v3`, which references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. A mutable tag can be silently updated to point to different (potentially malicious) code. It should be pinned to a full SHA, e.g., `github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:148`

### github-env-injection (severity: high)

In the 'Install Aguara' step, the env var `INSTALL_DIR` is set from `${{ runner.temp }}/aguara-bin` — a workflow-controllable context value — and then written directly to `$GITHUB_PATH` via `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without the required sanitization step (`printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`). A calling workflow that controls `runner.temp` could inject newlines to smuggle additional entries into `$GITHUB_PATH`.

Locations:

- `action.yml:103`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

Three fixes applied to hardened/action/action.yml:
1. unsafe-shell (line 102): Replaced `curl ... | bash` pipe with download-to-temp-file-then-execute pattern. The install script is now saved to a mktemp file via `-o`, executed with `bash`, then removed.
2. github-env-injection (line 103): Added sanitization of INSTALL_DIR before writing to $GITHUB_PATH using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` to strip any injected newlines.
3. unpinned-uses (line 148): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

