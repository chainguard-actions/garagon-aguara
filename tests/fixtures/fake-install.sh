#!/bin/sh
# Fake install.sh: installs a mock aguara binary into INSTALL_DIR
set -eu

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$INSTALL_DIR"

cat > "${INSTALL_DIR}/aguara" << 'AGUARA_EOF'
#!/bin/sh
# Mock aguara binary for testing
# Supports: scan, version subcommands

if [ "${1:-}" = "version" ]; then
  echo "aguara v0.23.0 (mock)"
  exit 0
fi

if [ "${1:-}" = "scan" ]; then
  # Parse arguments to find output file and format
  output_file=""
  format="sarif"
  fail_on=""
  prev=""
  for arg in "$@"; do
    case "$prev" in
      -o|--output) output_file="$arg" ;;
      --format) format="$arg" ;;
      --fail-on) fail_on="$arg" ;;
    esac
    prev="$arg"
  done

  # Write output based on format
  if [ -n "$output_file" ]; then
    if [ "$format" = "sarif" ]; then
      cat > "$output_file" << 'SARIF_EOF'
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "aguara",
          "version": "0.23.0"
        }
      },
      "results": []
    }
  ]
}
SARIF_EOF
    elif [ "$format" = "json" ]; then
      cat > "$output_file" << 'JSON_EOF'
{"findings": []}
JSON_EOF
    fi
  fi

  echo "Scan complete. No findings."
  exit 0
fi

echo "Unknown command: ${1:-}"
exit 1
AGUARA_EOF

chmod +x "${INSTALL_DIR}/aguara"
echo "  > Installed mock aguara to ${INSTALL_DIR}/aguara"
