<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

Step 'Install Aguara' downloads install.sh with curl and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The ref is checked first (semver tag or 40-char SHA), but the script still runs without being saved to a file and verified. Tags can be moved and no checksum is checked.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

A composite action step uses a mutable tag instead of a full commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

### github-env-injection (severity: medium)

Step 'Install Aguara' runs `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` without the `printf '%s' ... | tr -d '\n\r'` sanitization. INSTALL_DIR is set in the step's env: block from `${{ runner.temp }}/aguara-bin`, not computed inside the run: script, so the rule requires sanitization. runner.temp is set by the runner, not by an attacker, so the practical risk is low. That is why this is rated medium instead of the check's default high.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three findings are fixed in action.yml. I didn't run the action afterwards.

- **unsafe-shell:** the install step no longer downloads install.sh and pipes it into bash. By default it now runs the install.sh that ships with the action (`$GITHUB_ACTION_PATH/install.sh`), which comes from the same pinned commit, so nothing is fetched at all. If `install-script-ref` is set (the self-testing case), it downloads the script to a temp file and only runs it if the file isn't empty and its first line is `#!/bin/sh`. That check guards against an empty or wrong download, but it isn't a checksum. The ref check (semver tag or 40-char SHA) is unchanged. The script is run with plain `bash "$file"`, as upstream's pipe was; install.sh sets `set -eu` itself.
- **Side effect of the unsafe-shell fix:** when `install-script-ref` is blank, the ref the consumer pinned (`github.action_ref`) no longer picks which install.sh runs. The bundled copy from that pinned commit is used instead.
- **unpinned-uses:** `github/codeql-action/upload-sarif` is pinned to commit 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3).
- **github-env-injection:** the `GITHUB_PATH` line is now written with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`, followed by a newline.

