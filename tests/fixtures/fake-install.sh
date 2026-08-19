#!/bin/sh
# Fake install.sh: installs a mock aguara binary into INSTALL_DIR
set -eu

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$INSTALL_DIR"

cat > "${INSTALL_DIR}/aguara" << 'AGUARA_BINARY'
#!/bin/sh
# Mock aguara binary for testing
# Supports: version, scan

case "${1:-}" in
  version)
    echo "aguara v0.22.2 (mock)"
    exit 0
    ;;
  scan)
    # Parse arguments to find output file and format
    output_file=""
    format="sarif"
    fail_on=""
    prev=""
    for arg in "$@"; do
      case "$prev" in
        -o) output_file="$arg" ;;
        --format) format="$arg" ;;
        --fail-on) fail_on="$arg" ;;
      esac
      prev="$arg"
    done

    # Write output based on format
    if [ -n "$output_file" ]; then
      if [ "$format" = "sarif" ]; then
        cat > "$output_file" << 'SARIF'
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "aguara",
          "version": "0.22.2"
        }
      },
      "results": []
    }
  ]
}
SARIF
      elif [ "$format" = "json" ]; then
        cat > "$output_file" << 'JSON'
{"findings": []}
JSON
      fi
    fi

    echo "Scan complete. No findings."
    exit 0
    ;;
  *)
    echo "Usage: aguara <command> [options]"
    exit 1
    ;;
esac
AGUARA_BINARY

chmod +x "${INSTALL_DIR}/aguara"
echo "  > Installed mock aguara to ${INSTALL_DIR}/aguara"
