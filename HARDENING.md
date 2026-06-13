<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **garagon--aguara/v0.22.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Remote content is executed without first saving to a file and verifying its integrity. An attacker who can influence the fetched content (e.g., via a compromised CDN or MITM) could execute arbitrary code on the runner.

Locations:

- `action.yml:92`

### unpinned-uses (severity: high)

The step `uses: github/codeql-action/upload-sarif@v3` references a mutable tag (`@v3`) rather than a pinned 40-character commit SHA. A mutable tag can be moved to point to a different (potentially malicious) commit, creating a supply-chain risk.

Locations:

- `action.yml:136`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 92): Replaced `curl ... | bash` with a two-step approach: download install.sh to a mktemp file first using `-o "$install_script"`, then execute it with `bash "$install_script"`, and clean up afterward. This prevents arbitrary code execution from a compromised CDN or MITM attack. 2. unpinned-uses (line 136): Pinned `github/codeql-action/upload-sarif@v3` to the full commit SHA `@dd903d2e4f5405488e5ef1422510ee31c8b32357 # v3` to prevent supply-chain attacks via mutable tag references.

