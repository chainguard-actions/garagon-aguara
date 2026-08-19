#!/bin/sh
# Fake curl: intercepts aguara install.sh downloads and serves the fake install script.
# Supports both "curl URL | sh" (stdout) and "curl -o FILE URL" (file) forms.
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *garagon/aguara*install.sh*)
    if [ -n "$out" ]; then
      cat /tmp/fake-install.sh > "$out"
    else
      cat /tmp/fake-install.sh
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
