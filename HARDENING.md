<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The Install Aguara step downloads a remote script and pipes it straight into bash: curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash. The script should be saved to a file first, checked, and then run.

Locations:

- `action.yml:71`

### unpinned-uses (severity: high)

A composite step uses a mutable tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:139`

### github-env-injection (severity: high)

The Install Aguara step writes INSTALL_DIR to GITHUB_PATH without sanitizing it first: echo "$INSTALL_DIR" >> "$GITHUB_PATH". INSTALL_DIR comes from the env block (${{ runner.temp }}/aguara-bin), not from a literal computed in the same script. The value should go through printf '%s' "$INSTALL_DIR" | tr -d '\n\r' right before the write.

Locations:

- `action.yml:73`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three findings are fixed in action.yml. Nothing was run or tested.

- **unsafe-shell:** install.sh is now saved to a temp file with curl -o. The step stops if the file is empty, otherwise runs it with `bash "$file"` and then deletes it. Upstream piped it into a plain `bash` without arguments, so there was no `--` to drop. The installer still gets VERSION, INSTALL_DIR and GITHUB_TOKEN from the env block as before.
- **unpinned-uses:** github/codeql-action/upload-sarif@v3 is now pinned to `@4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3`.
- **github-env-injection:** INSTALL_DIR goes through `printf '%s' | tr -d '\n\r'` before it is written to $GITHUB_PATH.

One possible problem I left alone: the step decides which install.sh to download from github.action_ref. If someone pins this hardened copy by its own commit SHA, that SHA passes the check but probably doesn't exist in garagon/aguara, so the download would fail. Pinning by a vX.Y.Z tag that matches an upstream release works, and so does setting install-script-ref.

