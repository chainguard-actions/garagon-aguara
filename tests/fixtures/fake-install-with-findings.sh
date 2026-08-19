#!/bin/sh
# Fake install.sh: installs a mock aguara binary that reports findings
set -eu

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$INSTALL_DIR"

cat > "${INSTALL_DIR}/aguara" << 'AGUARA_BINARY'
#!/bin/sh
# Mock aguara binary that reports findings

case "${1:-}" in
  version)
    echo "aguara v0.22.2 (mock)"
    exit 0
    ;;
  scan)
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
      "results": [
        {
          "ruleId": "AGUARA-001",
          "level": "warning",
          "message": {"text": "Potential prompt injection detected"}
        },
        {
          "ruleId": "AGUARA-002",
          "level": "error",
          "message": {"text": "Data exfiltration risk detected"}
        }
      ]
    }
  ]
}
SARIF
      elif [ "$format" = "json" ]; then
        cat > "$output_file" << 'JSON'
{"findings": [{"id": "AGUARA-001", "severity": "medium"}, {"id": "AGUARA-002", "severity": "high"}]}
JSON
      fi
    fi

    echo "Scan complete. 2 findings detected."
    # Exit 1 when fail-on is set (simulating findings at or above threshold)
    if [ -n "$fail_on" ]; then
      exit 1
    fi
    exit 0
    ;;
  *)
    echo "Usage: aguara <command> [options]"
    exit 1
    ;;
esac
AGUARA_BINARY

chmod +x "${INSTALL_DIR}/aguara"
echo "  > Installed mock aguara (with findings) to ${INSTALL_DIR}/aguara"
