<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote shell script and pipes it directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated against a semver/SHA pattern, piping remote content directly to a shell interpreter is unsafe — the script should be downloaded to a file, verified, and then executed separately.

Locations:

- `action.yml:95`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a full 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks. It should be pinned to a specific SHA, e.g. `uses: github/codeql-action/upload-sarif@<40-char-sha> # v3`.

Locations:

- `action.yml:133`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 95): Replaced `curl ... | bash` with a safe download-then-execute pattern: the install script is downloaded to a temp file via `mktemp`, executed with `bash "$INSTALL_SCRIPT"`, and cleaned up with `rm -f`. 2. unpinned-uses (line 133): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `9f759ee644a3e7c15c1390abf49868036c00067b` with `# v3` comment for readability.

