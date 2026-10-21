<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Download the script to a file first, check it (for example with a checksum), then run it as a separate command.

Locations:

- `action.yml:98`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` with no sanitization. INSTALL_DIR comes from a step env: expression (`${{ runner.temp }}/aguara-bin`) rather than a literal computed in the run: block. Strip newlines first: `safe=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')`, then write "$safe".

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

The composite step references an action by a mutable tag instead of a 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

unsafe-shell: install.sh is now downloaded to a temp file with mktemp and curl -o. The step stops if the file is empty or doesn't start with '#!'. It logs the file's sha256 hash, runs it with 'bash "$file"' (upstream piped it into bash, so no extra options were added) and then deletes it. It still fetches from the same ref, which must be a semver tag or a 40-char SHA. The hash is only logged, not compared to a known value, because the ref changes with each release, so there's no fixed checksum to check against. github-env-injection: newlines are stripped from INSTALL_DIR before it is written to GITHUB_PATH. unpinned-uses: github/codeql-action/upload-sarif is now pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3). None of this was run or tested here.

