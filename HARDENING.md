<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote script and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download install.sh to a file first (and ideally verify its checksum), then run it as a separate command.

Locations:

- `action.yml:98`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR comes from an env: expression (`${{ runner.temp }}/aguara-bin`), not from a literal computed inside the same run block. The required `printf '%s' ... | tr -d '\n\r'` sanitization is not applied before the write.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

A composite step uses a mutable tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`. Pin it to a 40-character commit SHA.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

Three fixes in action.yml:
- unsafe-shell: install.sh is now saved to a mktemp file with curl -o and then run with 'bash "$INSTALL_SCRIPT"'. Its env variables (VERSION, INSTALL_DIR, GITHUB_TOKEN) are unchanged. No checksum check was added because upstream publishes no checksum for install.sh. The existing ref check (semver tag or 40-char SHA only) still controls which version is downloaded.
- github-env-injection: INSTALL_DIR now goes through printf '%s' | tr -d '\n\r' before it is written to $GITHUB_PATH.
- unpinned-uses: github/codeql-action/upload-sarif is pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3), the SHA lookup_action_sha returned for v3.

