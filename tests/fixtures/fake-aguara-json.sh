#!/bin/sh
# Fake aguara binary - writes empty JSON output
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
if [ -n "$output_file" ] && [ "$format" = "json" ]; then
  printf '{"findings": []}\n' > "$output_file"
fi
exit 0
