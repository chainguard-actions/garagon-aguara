<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh with curl and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The ref is checked to be a semver tag or a SHA, but the script is still run as it streams in, without being saved to a file first or checked against a checksum.

Locations:

- `action.yml:98`

### unpinned-uses (severity: high)

The composite step `uses: github/codeql-action/upload-sarif@v3` points to a tag that can be moved, not a full 40-character commit SHA.

Locations:

- `action.yml:168`

### github-env-injection (severity: high)

The 'Install Aguara' step runs `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR comes from the step's env: block (`${{ runner.temp }}/aguara-bin`), not from a value built inside the run: script. It is written to GITHUB_PATH without first passing through `printf '%s' ... | tr -d '\n\r'`. runner.temp is not attacker-controlled, so the real risk is low, but the check requires that step for any value not computed in the same run: block.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three findings are fixed in action.yml. I haven't run the action to test the changes.

- **unsafe-shell:** install.sh is now saved to a temp file made with mktemp, instead of being piped straight into bash. The step stops if the downloaded file is empty. Otherwise it runs the file with `bash "$INSTALL_SCRIPT"` and then deletes it. The existing check that the ref is a semver tag or a 40-character SHA is unchanged. There is still no checksum check, because upstream doesn't publish one for install.sh.
- **unpinned-uses:** `github/codeql-action/upload-sarif@v3` is now pinned to `@4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3`. I got that SHA from lookup_action_sha.
- **github-env-injection:** INSTALL_DIR now goes through `printf '%s' | tr -d '\n\r'` before it is written to GITHUB_PATH.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned github/codeql-action/upload-sarif@v3 to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3), the SHA returned by lookup_action_sha. Also fixed a broken line in the scan step's JSON branch: an earlier edit had put the pin text inside the jq command. It now reads `jq '.findings | length // 0' "$INPUT_OUTPUT"` again.

### Iteration 3

**Fixes applied:** unpinned-uses, invalid-yaml

**Notes:**

Replaced the leftover `uses: github/codeql-action/upload-sarif@v3` line and the unindented line that combined the pinned uses: with sarif_file:. The step is now a single pinned `uses: github/codeql-action/upload-sarif@4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3` (SHA checked again with lookup) followed by a correctly indented `with:` block containing sarif_file and wait-for-processing. A search found no other real unpinned uses: steps. The other two matches are inside an input's description text. Not run or parsed after the edit.

