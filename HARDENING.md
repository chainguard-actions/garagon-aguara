<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh with curl and pipes it straight into bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Remote content runs without being saved to a file or checked first. Download it to a file, verify it, then run it as a separate command.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

A composite step points to a version tag instead of a full 40-character commit SHA: `uses: github/codeql-action/upload-sarif@v3`. Pin it to a commit SHA.

Locations:

- `action.yml:169`

### github-env-injection (severity: high)

The 'Install Aguara' step writes `echo "$INSTALL_DIR" >> "$GITHUB_PATH"`. INSTALL_DIR comes from the step's env: block (`${{ runner.temp }}/aguara-bin`) and is not computed inside the same run: script. Under this check's rule, only a value computed in the same run: block may be written to a special file without sanitizing it, so this write needs `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` first. Note that runner.* is not in the check's list of untrusted contexts; this finding comes from the strict 'computed inside the same run: block' rule.

Locations:

- `action.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, github-env-injection

**Notes:**

All three findings are fixed in action.yml. Nothing has been run or tested yet.

- **unsafe-shell:** the install step no longer pipes install.sh into bash. It now downloads the script with curl -o to a mktemp file under RUNNER_TEMP. The step stops if the file is empty or its first line isn't a shebang (#!). Otherwise it runs the file with bash and then deletes it. The ref check upstream already had (semver tag or 40-character SHA only) is unchanged.
- **unpinned-uses:** github/codeql-action/upload-sarif is pinned to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 (v3).
- **github-env-injection:** INSTALL_DIR has newlines stripped with printf '%s' | tr -d '\n\r' before it is written to GITHUB_PATH.

The new check on install.sh only confirms it is a non-empty shell script. It doesn't compare a checksum, so it won't detect a tampered script.

### Iteration 2

**Fixes applied:** unpinned-uses

**Notes:**

Pinned github/codeql-action/upload-sarif@v3 to 4bfa242aa49c5f7c6770b98670d354a7dfac05f8 # v3 in action.yml.

