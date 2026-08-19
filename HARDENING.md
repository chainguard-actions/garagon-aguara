<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.1** was hardened automatically. 5 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

The 'Install Aguara' step in action.yml fetches install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remotely-fetched content without first saving it to a file for inspection, creating a supply-chain risk.

Locations:

- `action.yml:80`

### unpinned-uses (severity: high)

Multiple workflow files and action.yml use mutable tag refs instead of 40-character SHA pins, making them vulnerable to supply-chain attacks if the referenced action tag is moved.

action.yml:
- `uses: github/codeql-action/upload-sarif@v3`

.github/workflows/ci.yml:
- `uses: actions/checkout@v4`
- `uses: actions/setup-go@v6`

.github/workflows/docker.yml:
- `uses: actions/checkout@v4`
- `uses: docker/setup-qemu-action@v3`
- `uses: docker/setup-buildx-action@v3`
- `uses: docker/login-action@v3`
- `uses: docker/metadata-action@v5`
- `uses: docker/build-push-action@v7`

.github/workflows/intel-publish.yml:
- `uses: actions/checkout@v4`
- `uses: actions/setup-go@v6`

.github/workflows/release.yml:
- `uses: actions/checkout@v4`
- `uses: actions/setup-go@v6`

.github/workflows/test-action.yml:
- `uses: actions/checkout@v4` (appears 3 times)

Locations:

- `action.yml:136`
- `.github/workflows/ci.yml:15`
- `.github/workflows/ci.yml:17`
- `.github/workflows/docker.yml:22`
- `.github/workflows/docker.yml:26`
- `.github/workflows/docker.yml:32`
- `.github/workflows/docker.yml:34`
- `.github/workflows/docker.yml:49`
- `.github/workflows/docker.yml:55`
- `.github/workflows/intel-publish.yml:37`
- `.github/workflows/intel-publish.yml:43`
- `.github/workflows/release.yml:19`
- `.github/workflows/release.yml:23`
- `.github/workflows/test-action.yml:17`

### missing-permissions (severity: medium)

The workflow file .github/workflows/ci.yml has no top-level `permissions:` key and its only job (`test`) also has no job-level `permissions:` key. This means the workflow runs with the default (potentially broad) token permissions.

Locations:

- `.github/workflows/ci.yml:1`

### script-injection (severity: high)

Sub-rule (a): `${{ github.ref_name }}` is interpolated directly inside two `run:` shell command strings in .github/workflows/release.yml. Although this workflow is only triggered on tag pushes (which limits who can trigger it), the expression still flows through YAML template substitution before the shell sees it.

Offending lines:
1. `git tag -fa v1 -m "v1 action alias → ${{ github.ref_name }}"` — the ref_name value is injected directly into a shell string.
2. `-f "client_payload[tag]=${{ github.ref_name }}"` — the ref_name value is injected directly into a shell argument.

Locations:

- `.github/workflows/release.yml:53`
- `.github/workflows/release.yml:62`

### script-injection (severity: high)

Sub-rule (b): In .github/workflows/docker.yml, the `Sign image` step sets `TAGS: ${{ steps.meta.outputs.tags }}` in its `env:` block and then uses the variable unquoted in the shell: `for tag in $TAGS; do`. The unquoted expansion allows the shell to word-split and glob-expand the value, which could be exploited if the `steps.meta.outputs.tags` value contains shell metacharacters.

Locations:

- `.github/workflows/docker.yml:89`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all 5 findings:
1. unsafe-shell (action.yml): Replaced `curl ... | bash` with download-then-execute pattern using mktemp.
2. unpinned-uses: Pinned all mutable tag refs to full 40-char SHAs across action.yml, ci.yml, docker.yml, intel-publish.yml, release.yml, and test-action.yml.
3. missing-permissions (ci.yml): Added `permissions: contents: read` top-level block.
4. script-injection (release.yml): Moved both `${{ github.ref_name }}` expressions from run: shell strings into env: blocks as REF_NAME, referenced as ${REF_NAME} in shell.
5. script-injection (docker.yml): Replaced unquoted `for tag in $TAGS` with `while IFS= read -r tag; do ... done <<< "$TAGS"` to prevent word-splitting/glob-expansion.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. The INSTALL_DIR value (derived from runner.temp) is now sanitized using `printf '%s' "$INSTALL_DIR" | tr -d '\n\r'` before being written to $GITHUB_PATH, preventing newline injection attacks that could hijack PATH lookups in subsequent steps.

