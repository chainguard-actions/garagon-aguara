<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches a remote shell script and pipes it directly to bash without first saving it to a file: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This pattern executes untrusted remote content without any opportunity to inspect it, and is vulnerable to MITM or supply-chain attacks on the remote host.

Locations:

- `action.yml:99`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a full 40-character commit SHA. A mutable tag can be silently updated to point to different (potentially malicious) code, making the action vulnerable to supply-chain attacks.

Locations:

- `action.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 99): Replaced `curl ... | bash` with a two-step approach: download install.sh to a temp file via `mktemp`, then execute it with `bash "$INSTALL_SCRIPT"`, then remove the temp file. This allows inspection before execution and eliminates the MITM/supply-chain risk of piping remote content directly to bash.
2. unpinned-uses (line 168): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `ce5e7eeac396d720fe2d802714996c8ce561e311`, preserving the tag as a `# v3` comment for readability.

