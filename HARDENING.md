<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.28.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.28.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action step 'Upload SARIF to GitHub Code Scanning' uses `github/codeql-action/upload-sarif@v4`, which is a mutable tag reference rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling supply-chain attacks. It should be pinned to a full SHA, e.g. `github/codeql-action/upload-sarif@<40-char-sha> # v4`.

Locations:

- `action.yml:183`

### unsafe-shell (severity: high)

The 'Install Aguara' step downloads a remote shell script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though INSTALL_REF is validated to be a semver tag or 40-char SHA, piping remote content directly to a shell interpreter without first saving and inspecting it is an unsafe pattern that can execute arbitrary code if the remote host or content is compromised.

Locations:

- `action.yml:116`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, unsafe-shell

**Notes:**

Fixed two security findings in hardened/action/action.yml:
1. unpinned-uses (line 183): Pinned `github/codeql-action/upload-sarif@v4` to the full commit SHA `b96794f015dfd88f77b49b1c93e0fa7110f94c63`, keeping the tag as a comment for readability.
2. unsafe-shell (line 116): Replaced the `curl ... | bash` pipe pattern with a two-step approach: download the install.sh script to a temp file using `mktemp`, then execute it separately with `bash "$INSTALL_SCRIPT"`. No `--` was present in the original pipe form so none needed to be dropped.

