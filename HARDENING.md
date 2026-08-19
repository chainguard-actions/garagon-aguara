<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.23.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.23.0** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml pipes a remotely-fetched script directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. The script is never saved to disk before execution, so there is no opportunity to inspect or verify it before it runs.

Locations:

- `action.yml:97`

### script-injection (severity: high)

Rule (a): Two run: blocks in release.yml directly interpolate `${{ github.ref_name }}` inside shell commands without routing through an env: variable. (1) `git tag -fa v1 -m "v1 action alias → ${{ github.ref_name }}"` — a crafted tag name could inject shell metacharacters into the git command. (2) `-f "client_payload[tag]=${{ github.ref_name }}"` — same issue in the gh api call. Both are direct expression interpolations inside run: scripts.

Locations:

- `.github/workflows/release.yml:53`
- `.github/workflows/release.yml:64`

### script-injection (severity: high)

Rule (b): The 'Sign image' step in docker.yml uses `for tag in $TAGS; do` where `$TAGS` is set from `${{ steps.meta.outputs.tags }}` (a steps.*.outputs.* value). The variable is unquoted in the for-loop word-splitting context, allowing shell metacharacters in the tag list to be interpreted by the shell.

Locations:

- `.github/workflows/docker.yml:90`

### unpinned-uses (severity: high)

Multiple workflow files and action.yml reference actions by mutable tag instead of a full 40-character commit SHA, making them vulnerable to supply-chain attacks if the tag is moved. Unpinned references found:
- action.yml: `github/codeql-action/upload-sarif@v3`
- .github/workflows/ci.yml: `actions/checkout@v4`, `actions/setup-go@v6`
- .github/workflows/docker.yml: `actions/checkout@v4`, `docker/setup-qemu-action@v3`, `docker/setup-buildx-action@v3`, `docker/login-action@v3`, `docker/metadata-action@v5`, `docker/build-push-action@v7`
- .github/workflows/intel-publish.yml: `actions/checkout@v4`, `actions/setup-go@v6`
- .github/workflows/release.yml: `actions/checkout@v4`, `actions/setup-go@v6`
- .github/workflows/test-action.yml: `actions/checkout@v4` (appears in three jobs)

Locations:

- `action.yml:143`
- `.github/workflows/ci.yml:14`
- `.github/workflows/ci.yml:16`
- `.github/workflows/docker.yml:24`
- `.github/workflows/docker.yml:28`
- `.github/workflows/docker.yml:34`
- `.github/workflows/docker.yml:36`
- `.github/workflows/docker.yml:52`
- `.github/workflows/docker.yml:61`
- `.github/workflows/intel-publish.yml:38`
- `.github/workflows/intel-publish.yml:43`
- `.github/workflows/release.yml:19`
- `.github/workflows/release.yml:23`
- `.github/workflows/test-action.yml:22`

### missing-permissions (severity: medium)

ci.yml has no top-level `permissions:` key and no job-level `permissions:` key on any of its jobs. Without explicit permissions, the workflow inherits the repository default (typically `contents: write` for private repos or `contents: read` for public repos), granting broader access than necessary for a CI workflow that only builds, lints, and tests.

Locations:

- `.github/workflows/ci.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all 5 findings:
1. unsafe-shell (action.yml line 97): Replaced `curl ... | bash` with download-then-execute pattern using mktemp.
2. script-injection (release.yml lines 53, 64): Moved `${{ github.ref_name }}` into env: REF_NAME variable in both affected steps.
3. script-injection (docker.yml line 90): Replaced unquoted `for tag in $TAGS` with safe `while IFS= read -r tag; do ... done <<< "$TAGS"` pattern.
4. unpinned-uses: Pinned all mutable tag references to full SHAs — actions/checkout@v4→11d5960a, actions/setup-go@v6→924ae3a1, docker/setup-qemu-action@v3→c7c53464, docker/setup-buildx-action@v3→8d2750c6, docker/login-action@v3→c94ce9fb, docker/metadata-action@v5→c299e40c, docker/build-push-action@v7→53b7df96, github/codeql-action/upload-sarif@v3→b7351df7.
5. missing-permissions (ci.yml): Added top-level `permissions: contents: read` block.

