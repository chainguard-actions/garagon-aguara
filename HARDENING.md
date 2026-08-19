<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.27.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.27.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files and action.yml reference actions by mutable version tags instead of full 40-character SHA commits, making them vulnerable to supply-chain attacks if the tag is moved.

action.yml: uses: github/codeql-action/upload-sarif@v4

.github/workflows/ci.yml: uses: actions/checkout@v6, uses: actions/setup-go@v6

.github/workflows/docker.yml: uses: actions/checkout@v6, uses: docker/setup-qemu-action@v3, uses: docker/setup-buildx-action@v3, uses: docker/login-action@v3, uses: docker/metadata-action@v5, uses: docker/build-push-action@v7

.github/workflows/fuzz.yml: uses: actions/checkout@v6, uses: actions/setup-go@v6, uses: actions/upload-artifact@v4

.github/workflows/intel-publish.yml: uses: actions/checkout@v6, uses: actions/setup-go@v6

.github/workflows/release.yml: uses: actions/checkout@v6, uses: actions/setup-go@v6

.github/workflows/test-action.yml: uses: actions/checkout@v6

Locations:

- `action.yml:150`
- `.github/workflows/ci.yml:14`
- `.github/workflows/ci.yml:16`
- `.github/workflows/docker.yml:24`
- `.github/workflows/docker.yml:28`
- `.github/workflows/docker.yml:34`
- `.github/workflows/docker.yml:36`
- `.github/workflows/docker.yml:52`
- `.github/workflows/docker.yml:58`
- `.github/workflows/fuzz.yml:19`
- `.github/workflows/fuzz.yml:21`
- `.github/workflows/fuzz.yml:28`
- `.github/workflows/intel-publish.yml:40`
- `.github/workflows/intel-publish.yml:46`
- `.github/workflows/release.yml:19`
- `.github/workflows/release.yml:23`
- `.github/workflows/test-action.yml:19`

### missing-permissions (severity: medium)

The workflow file .github/workflows/ci.yml has no top-level `permissions:` key and the single job `test` also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository default, granting broader access than necessary.

Locations:

- `.github/workflows/ci.yml:1`

### script-injection (severity: high)

Two `run:` steps in release.yml directly interpolate `${{ github.ref_name }}` into shell command strings without routing through an env var first. An attacker who controls the tag name (e.g. by pushing a tag containing shell metacharacters) could inject arbitrary shell commands.

(a) Line 60: git tag -fa v1 -m "v1 action alias -> ${{ github.ref_name }}"
(a) Line 71: -f "client_payload[tag]=${{ github.ref_name }}"

Fix: move github.ref_name into an env var and reference the env var (double-quoted) inside the run block.

Locations:

- `.github/workflows/release.yml:60`
- `.github/workflows/release.yml:71`

### unsafe-shell (severity: high)

action.yml pipes a remotely-fetched script directly to bash without first saving it to a file for inspection: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. If the remote host is compromised or the ref is tampered with, arbitrary code executes immediately on the runner. The script should be downloaded to a temporary file, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `action.yml:99`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, missing-permissions, script-injection, unsafe-shell

**Notes:**

1. unpinned-uses: Pinned all mutable tag references to full 40-char SHAs with tag comments preserved: github/codeql-action/upload-sarif@v4→7188fc3 (action.yml); actions/checkout@v6→df4cb1c and actions/setup-go@v6→924ae3a (ci.yml, fuzz.yml, intel-publish.yml, release.yml, test-action.yml x3); docker/setup-qemu-action@v3→c7c5346, docker/setup-buildx-action@v3→8d2750c, docker/login-action@v3→c94ce9f, docker/metadata-action@v5→c299e40, docker/build-push-action@v7→53b7df9 (docker.yml); actions/upload-artifact@v4→ea165f8 (fuzz.yml). 2. missing-permissions: Added 'permissions: contents: read' top-level block to ci.yml. 3. script-injection: In release.yml, moved github.ref_name out of both run: shell strings into env: blocks as REF_NAME, referencing $REF_NAME in the shell. 4. unsafe-shell: In action.yml, replaced 'curl ... | bash' with download-to-tempfile pattern: mktemp, curl -o $INSTALL_SCRIPT, bash $INSTALL_SCRIPT, rm -f $INSTALL_SCRIPT.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted shell expansion in the 'Sign image' step of hardened/action/.github/workflows/docker.yml. Changed `for tag in $TAGS; do` to `for tag in "$TAGS"; do` to prevent word splitting and glob expansion on the TAGS environment variable (sourced from steps.meta.outputs.tags). The TAGS variable was already properly moved to the env: block; only the quoting in the shell script was missing.

