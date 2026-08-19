<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.2** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step fetches install.sh from a remote URL and pipes it directly to bash without first saving it to a file for inspection. Pattern: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This allows a compromised or man-in-the-middle response to execute arbitrary code immediately.

Locations:

- `action.yml:87`

### unpinned-uses (severity: high)

The action uses `github/codeql-action/upload-sarif@v3`, which is pinned to a mutable tag (`v3`) rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit without notice, creating a supply-chain risk.

Locations:

- `action.yml:155`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses

**Notes:**

1. unsafe-shell (line 87): Replaced `curl ... | bash` with a two-step approach: download install.sh to ${RUNNER_TEMP}/aguara-install.sh using curl's -o flag, then execute it with `bash "$INSTALL_SCRIPT"`. This prevents a compromised or MITM response from executing arbitrary code immediately. 2. unpinned-uses (line 155): Replaced `github/codeql-action/upload-sarif@v3` with the pinned immutable SHA `github/codeql-action/upload-sarif@4187e74d05793876e9989daffde9c3e66b4acd07 # v3`, resolved via lookup_action_sha.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all 4 findings across 5 workflow files:

1. unpinned-uses: Pinned all 13 unpinned action references to full 40-char SHAs with tag comments preserved. Actions pinned: actions/checkout@v4, actions/setup-go@v6, docker/setup-qemu-action@v3, docker/setup-buildx-action@v3, docker/login-action@v3, docker/metadata-action@v5, docker/build-push-action@v7.

2. missing-permissions: Added `permissions: contents: read` top-level block to ci.yml (the only workflow missing it).

3. script-injection (release.yml, 2 locations): Moved `${{ github.ref_name }}` into `env: REF_NAME:` in both the 'Update v1 action tag' step and the 'Trigger observatory rescan' step, then referenced as `$REF_NAME` in the shell scripts.

4. script-injection (docker.yml, line 93): Replaced unquoted `for tag in $TAGS` loop with `while IFS= read -r tag; do ... done <<< "$TAGS"` to safely iterate over newline-separated tags without shell word-splitting on metacharacters.

