<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a script and pipes it straight into bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The ref is checked against a semver tag or 40-char SHA pattern, but the script is never saved to a file and checked before it runs. Download it to a file, verify its checksum, then run it as a separate command.

Locations:

- `action.yml:98`

### github-env-injection (severity: high)

The 'Install Aguara' step writes an env-var value to $GITHUB_PATH without sanitizing it first: `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR is set in the step's env: block (`${{ runner.temp }}/aguara-bin`), not computed inside the run: script. The check requires `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before the write.

Locations:

- `action.yml:100`

### unpinned-uses (severity: high)

A composite step in action.yml uses a version tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, unpinned-uses

**Notes:**

I fixed all three findings in action.yml. I haven't run the action since the changes.

- **unsafe-shell:** The 'Install Aguara' step no longer downloads install.sh with curl and pipes it into bash. It now runs the install.sh that ships with the pinned action, found through github.action_path and run with `bash "$INSTALL_SCRIPT"`. I didn't add a checksum for the script because nothing is downloaded any more. Upstream also ran it with plain `bash`, and the script turns on `set -eu` itself. It still checks the release archive's SHA-256 against checksums.txt before installing. If the bundled file is missing, the step stops with an error.
- **github-env-injection:** INSTALL_DIR is passed through `printf '%s' | tr -d '\n\r'` before it is written to $GITHUB_PATH.
- **unpinned-uses:** github/codeql-action/upload-sarif is pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3, the SHA that lookup_action_sha returned for v3.

**One behaviour change:** the `install-script-ref` input no longer does anything. Upstream used it to pick which ref install.sh was downloaded from. Now that nothing is downloaded, setting it only prints a notice. This mainly matters for upstream's own self-tests that run the action with `uses: ./`. In that case the bundled script comes from the local checkout anyway, so they still get the script from the commit under test. The ACTION_REF env variable in that step is now unused but still there.

