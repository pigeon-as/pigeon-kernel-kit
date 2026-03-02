#!/bin/bash
set -euo pipefail

CONFIG="${1:?missing <config_path>}"

# Auto-discover expected symbols from pigeon fragment configs.
# No manual list to keep in sync — add a symbol to a fragment and
# verify.sh picks it up automatically.
mapfile -t ENABLED < <(grep -h '^CONFIG_.*=y' configs/pigeon/*.config | cut -d= -f1)
mapfile -t DISABLED < <(grep -h '^# CONFIG_.* is not set' configs/pigeon/*.config | awk '{print $2}')

failures=0

for key in "${ENABLED[@]}"; do
  if ! grep -q "^${key}=y$" "${CONFIG}"; then
    echo "FAIL: ${key}=y not found" >&2
    ((failures++))
  fi
done

for key in "${DISABLED[@]}"; do
  if ! grep -q "^# ${key} is not set$" "${CONFIG}"; then
    echo "FAIL: ${key} not disabled" >&2
    ((failures++))
  fi
done

if (( failures > 0 )); then
  echo "FAILED (${failures} issue(s))" >&2
  exit 1
fi

echo "OK (${#ENABLED[@]} enabled, ${#DISABLED[@]} disabled)"
