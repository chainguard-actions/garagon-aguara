#!/bin/sh
# Fake install.sh: installs a mock aguara binary that reports findings
set -eu

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
mkdir -p "$INSTALL_DIR"

cat > "${INSTALL_DIR}/aguara" << 'AGUARA_EOF'
#!/bin/sh
# Mock aguara binary for testing - reports findings

if [ "${1:-}" = "version" ]; then
  echo "aguara v0.23.0 (mock)"
  exit 0
fi

if [ "${1:-}" = "scan" ]; then
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
      "results": [
        {
          "ruleId": "AGUARA-001",
          "level": "error",
          "message": {"text": "Prompt injection detected"},
          "locations": []
        }
      ]
    }
  ]
}
SARIF_EOF
    elif [ "$format" = "json" ]; then
      cat > "$output_file" << 'JSON_EOF'
{"findings": [{"id": "AGUARA-001", "severity": "high", "message": "Prompt injection detected"}]}
JSON_EOF
    fi
  fi

  echo "Scan complete. 1 finding(s) detected."
  # Exit 1 if fail-on is set (simulating a finding at or above threshold)
  if [ -n "$fail_on" ]; then
    exit 1
  fi
  exit 0
fi

echo "Unknown command: ${1:-}"
exit 1
AGUARA_EOF

chmod +x "${INSTALL_DIR}/aguara"
echo "  > Installed mock aguara (with findings) to ${INSTALL_DIR}/aguara"
