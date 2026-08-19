#!/bin/sh
set -eu
install_dir="${INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$install_dir"
cp "$GITHUB_WORKSPACE/tests/fixtures/fake-aguara-sarif.sh" "${install_dir}/aguara"
chmod +x "${install_dir}/aguara"
