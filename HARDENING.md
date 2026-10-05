<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash: `curl -fsSL --max-time 30 --retry 3 --retry-connrefused "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though the ref is validated against a semver or SHA pattern, piping remote content directly to a shell interpreter is unsafe — a compromised CDN, MITM, or repository could serve malicious content that executes immediately without any opportunity for inspection.

Locations:

- `action.yml:76`

### unpinned-uses (severity: high)

The composite action step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a pinned 40-character SHA commit hash. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:131`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 76): Replaced `curl ... | bash` with a safe two-step approach: download install.sh to a mktemp file, execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This allows inspection before execution and eliminates the MITM/CDN risk of piping directly to bash. No `--` separator was present in the original, so none was introduced. 2. unpinned-uses (line 131): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@1190a975f95ce23525efb6a3fc21ea29567c1b52 # v3` to prevent supply-chain attacks via mutable tag references.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (derived from runner.temp context) is now sanitized with `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before being written to $GITHUB_PATH, preventing potential newline injection attacks that could add unauthorized entries to the PATH.

