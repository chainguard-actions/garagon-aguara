<!-- markdownlint-disable -->

# Hardening Report: garagon--aguara/v0.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **garagon--aguara/v0.24.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references are pinned to mutable tags instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the tag is moved. Failing references:
- action.yml: `github/codeql-action/upload-sarif@v3`
- .github/workflows/ci.yml: `actions/checkout@v4`, `actions/setup-go@v6`
- .github/workflows/docker.yml: `actions/checkout@v4`, `docker/setup-qemu-action@v3`, `docker/setup-buildx-action@v3`, `docker/login-action@v3`, `docker/metadata-action@v5`, `docker/build-push-action@v7`
- .github/workflows/intel-publish.yml: `actions/checkout@v4`, `actions/setup-go@v6`
- .github/workflows/release.yml: `actions/checkout@v4`, `actions/setup-go@v6`
- .github/workflows/test-action.yml: `actions/checkout@v4`

Locations:

- `action.yml:130`
- `.github/workflows/ci.yml:16`
- `.github/workflows/ci.yml:18`
- `.github/workflows/docker.yml:24`
- `.github/workflows/docker.yml:28`
- `.github/workflows/docker.yml:34`
- `.github/workflows/docker.yml:36`
- `.github/workflows/docker.yml:48`
- `.github/workflows/docker.yml:55`
- `.github/workflows/intel-publish.yml:38`
- `.github/workflows/intel-publish.yml:44`
- `.github/workflows/release.yml:18`
- `.github/workflows/release.yml:22`
- `.github/workflows/test-action.yml:26`

### permissions (severity: medium)

`.github/workflows/ci.yml` has no top-level `permissions:` key and no job-level `permissions:` key on its `test` job. Without explicit permissions, the workflow inherits the repository's default token permissions, which may be overly broad (write access to contents, etc.).

Locations:

- `.github/workflows/ci.yml:1`

### script-injection (severity: high)

Two script-injection issues found:

(a) Direct expression interpolation in run: blocks in `.github/workflows/release.yml`: `${{ github.ref_name }}` is interpolated directly into shell commands in two steps — `git tag -fa v1 -m "v1 action alias → ${{ github.ref_name }}"` and `-f "client_payload[tag]=${{ github.ref_name }}"`. Although this workflow is triggered by tag pushes, the expression flows through YAML template substitution before the shell sees it, enabling injection if the tag name contains shell metacharacters.

(b) Unquoted shell variable expansion in `.github/workflows/docker.yml`: `for tag in $TAGS` where `TAGS` is set from `${{ steps.meta.outputs.tags }}`. The variable is expanded without double-quoting, allowing shell metacharacter injection from the step output value.

Locations:

- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:63`
- `.github/workflows/docker.yml:73`

### unsafe-shell (severity: high)

In `action.yml`, the Install Aguara step fetches a remote shell script and pipes it directly to bash: `curl -fsSL ... "https://raw.githubusercontent.com/garagon/aguara/${INSTALL_REF}/install.sh" | bash`. Even though `INSTALL_REF` is validated against a semver/SHA pattern, piping remote content directly to a shell interpreter is an unsafe pattern — if the remote host or the content is compromised, arbitrary code executes immediately without any opportunity for inspection.

Locations:

- `action.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, script-injection, unsafe-shell

**Notes:**

Fixed all four findings:

1. unpinned-uses: Pinned all mutable tag references to full 40-char commit SHAs in action.yml (codeql-action/upload-sarif), ci.yml (checkout, setup-go), docker.yml (checkout, setup-qemu-action, setup-buildx-action, login-action, metadata-action, build-push-action), intel-publish.yml (checkout, setup-go), release.yml (checkout, setup-go), and test-action.yml (checkout in all three jobs).

2. permissions: Added `permissions: contents: read` top-level block to .github/workflows/ci.yml which had no permissions key.

3. script-injection: (a) In release.yml, moved ${{ github.ref_name }} into env: REF_NAME for both the 'Update v1 action tag' and 'Trigger observatory rescan' steps. (b) In docker.yml, replaced unquoted `for tag in $TAGS` with `mapfile -t tag_list <<< "$TAGS"` and `for tag in "${tag_list[@]}"` to safely handle multi-line tag values.

4. unsafe-shell: In action.yml, replaced `curl ... | bash` with a two-step approach: download to a temp file with `curl -o "$INSTALL_SCRIPT"`, execute with `bash "$INSTALL_SCRIPT"`, then clean up with `rm -f "$INSTALL_SCRIPT"`.

