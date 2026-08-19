<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.22.0** was hardened automatically. 4 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

action.yml fetches install.sh from a remote URL and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. This executes remotely-fetched content without first saving it to a file for inspection, which is an unsafe shell pattern.

Locations:

- `action.yml:79`

### script-injection (severity: high)

release.yml interpolates `${{ github.ref_name }}` directly inside two `run:` shell command strings (sub-rule a). (1) `git tag -fa v1 -m "v1 action alias -> ${{ github.ref_name }}"` and (2) `gh api ... -f "client_payload[tag]=${{ github.ref_name }}"`. Any ${{ ... }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell parses the string.

Locations:

- `.github/workflows/release.yml:50`
- `.github/workflows/release.yml:58`

### unpinned-uses (severity: high)

Multiple workflow files and action.yml reference actions using mutable version tags instead of immutable 40-character commit SHAs. Failing references: action.yml: github/codeql-action/upload-sarif@v3; ci.yml: actions/checkout@v4, actions/setup-go@v6; docker.yml: actions/checkout@v4, docker/setup-qemu-action@v3, docker/setup-buildx-action@v3, docker/login-action@v3, docker/metadata-action@v5, docker/build-push-action@v7; intel-publish.yml: actions/checkout@v4, actions/setup-go@v6; release.yml: actions/checkout@v4, actions/setup-go@v6; test-action.yml: actions/checkout@v4 (x3).

Locations:

- `action.yml:131`
- `.github/workflows/ci.yml:14`
- `.github/workflows/ci.yml:16`
- `.github/workflows/docker.yml:21`
- `.github/workflows/docker.yml:25`
- `.github/workflows/docker.yml:28`
- `.github/workflows/docker.yml:31`
- `.github/workflows/docker.yml:44`
- `.github/workflows/docker.yml:48`
- `.github/workflows/intel-publish.yml:38`
- `.github/workflows/intel-publish.yml:42`
- `.github/workflows/release.yml:18`
- `.github/workflows/release.yml:22`
- `.github/workflows/test-action.yml:20`
- `.github/workflows/test-action.yml:55`
- `.github/workflows/test-action.yml:76`

### missing-permissions (severity: medium)

ci.yml has no top-level `permissions:` key and the single job `test` also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository default token permissions, which may be overly broad.

Locations:

- `.github/workflows/ci.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all four findings: (1) unsafe-shell in action.yml: replaced `curl | bash` with download-to-tempfile then execute pattern; (2) script-injection in release.yml: moved both `${{ github.ref_name }}` expressions into env: blocks as REF_NAME; (3) unpinned-uses: pinned all 16 mutable tag references across action.yml, ci.yml, docker.yml, intel-publish.yml, release.yml, and test-action.yml to full 40-char commit SHAs using lookup_action_sha; (4) missing-permissions in ci.yml: added top-level `permissions: contents: read` block.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Sign image' step of hardened/action/.github/workflows/docker.yml. Replaced the unquoted `for tag in $TAGS` (which allowed word splitting and glob expansion on the workflow-controllable `steps.meta.outputs.tags` value) with `readarray -t tags <<< "$TAGS"` to safely read the multi-line value into a bash array, then iterate with `for tag in "${tags[@]}"` to keep each tag properly quoted.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in the 'Install Aguara' step of action.yml. Replaced the direct `echo "$INSTALL_DIR" >> "$GITHUB_PATH"` with a sanitized version that first strips newline characters: `safe_install_dir=$(printf '%s' "$INSTALL_DIR" | tr -d '\n\r')` followed by `echo "$safe_install_dir" >> "$GITHUB_PATH"`. This prevents a malformed runner.temp value containing newlines from injecting arbitrary entries into $GITHUB_PATH.

