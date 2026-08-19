#!/bin/sh
# Fake aguara binary - writes SARIF with 1 finding, exits 1 when --fail-on is set
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
if [ -n "$output_file" ] && [ "$format" = "sarif" ]; then
  cat > "$output_file" << 'SARIF_EOF'
{
  "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {"driver": {"name": "aguara", "version": "0.0.1", "rules": []}},
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
fi
if [ -n "$fail_on" ]; then
  exit 1
fi
exit 0
