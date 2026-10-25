<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 3 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from raw.githubusercontent.com and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Checking that the ref looks like a semver tag or SHA does not make this safe. The script should be saved to a file first (ideally checksum-verified) and then run as a separate command.

Locations:

- `action.yml:97`

### unpinned-uses (severity: high)

A composite step references an action by a mutable tag instead of a 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:167`

### github-env-injection (severity: high)

The 'Install Aguara' step writes the env-sourced variable INSTALL_DIR (set in the step's env: block as `${{ runner.temp }}/aguara-bin`) to $GITHUB_PATH without the required sanitization: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. The value is not computed inside the run: block, so the check requires `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` right before the write.

Locations:

- `action.yml:99`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three findings are fixed in action.yml. I haven't run the action to test these changes.

- **unsafe-shell:** install.sh is no longer piped straight into bash. It's now saved to a temporary file with `mktemp` and `curl -o`, the step stops with an error if the file is empty, and then it runs as `bash "$INSTALL_SCRIPT"` and the file is deleted. The original `| bash` passed no arguments, so the new command passes none either. The file is not checked against a checksum, because the action has no published checksum to compare it to.
- **unpinned-uses:** `github/codeql-action/upload-sarif@v3` is now pinned to `@4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3`. I got that commit SHA by looking up the `v3` tag.
- **github-env-injection:** Before `INSTALL_DIR` is written to `$GITHUB_PATH`, newlines and carriage returns are now stripped with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'`.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned github/codeql-action/upload-sarif to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (# v3) in the 'Upload SARIF to GitHub Code Scanning' step; verified via lookup. Restored the corrupted JSON-count line in the 'Run Aguara scan' script to: count=$(jq '.findings | length // 0' "$INPUT_OUTPUT" 2>/dev/null || echo 0). The expression was reconstructed from the assertion in tests/test-json-format.yml, which compares findings-count against `.findings | length // 0`; upstream's exact text was not available to check against.

### Iteration 3

**Fixes applied:** invalid-yaml

**Notes:**

In the Upload SARIF step, an earlier edit had run the old cut-off uses: text, the new pinned uses: text and the sarif_file: line together on one line, and dropped the with: key. Replaced it with a single uses: github/codeql-action/upload-sarif@4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3 line and restored the with: block. The SHA was checked again for v3. The file was not re-parsed after the edit.

