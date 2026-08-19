#!/bin/sh
# Fake aguara binary - records args and writes empty SARIF output
echo "$@" > /tmp/aguara-args.txt
output_file=""
format="sarif"
prev=""
for arg in "$@"; do
  case "$prev" in
    -o) output_file="$arg" ;;
    --format) format="$arg" ;;
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
      "results": []
    }
  ]
}
SARIF_EOF
fi
exit 0
