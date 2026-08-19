#!/bin/sh
# Fake curl: intercept aguara install.sh URL, fall through for others
# Supports both pipe form (stdout) and hardened form (-o FILE)
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *install.sh*)
    if [ -n "$out" ]; then
      cat "$GITHUB_WORKSPACE/tests/fixtures/fake-install-verbose.sh" > "$out"
    else
      cat "$GITHUB_WORKSPACE/tests/fixtures/fake-install-verbose.sh"
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
