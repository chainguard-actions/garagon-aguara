<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote script and pipes it straight into bash without saving it to a file first: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script should be downloaded to a file, checked, and then run as a separate command.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

A composite step uses a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step writes an env-routed value to $GITHUB_PATH without the required sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`, where INSTALL_DIR is set from `${{ runner.temp }}/aguara-bin` in the step's env block. The value is not computed inside the run block, so it must go through `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before the write.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

I fixed all three findings in action.yml. Nothing has been run or tested yet.

- **unsafe-shell:** install.sh is now downloaded to a temp file with the same curl options as before. The step stops with an error if the file is empty. Otherwise it runs the file with `bash "$INSTALL_SCRIPT"` and then deletes it. Upstream passed no arguments to the script, so none are passed now. Apart from the empty-file check, nothing else verifies the download.
- **unpinned-uses:** I pinned `github/codeql-action/upload-sarif@v3` to `4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3`. I got that commit from a lookup of the v3 tag.
- **github-env-injection:** `INSTALL_DIR` now goes through `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before it is written to `$GITHUB_PATH`.

### Iteration 2

**Fixes applied:** unpinned-uses, invalid-yaml

**Notes:**

Undid the bad edit in the 'Run Aguara scan' run block: put back the closing 'fi', the blank line and the 'echo "findings-count=${count}" >> "$GITHUB_OUTPUT"' line. Pinned github/codeql-action/upload-sarif@v3 to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3. I got the SHA from lookup_action_sha.

