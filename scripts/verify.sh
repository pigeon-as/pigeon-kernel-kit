#!/bin/bash
set -euo pipefail

CONFIG="${1:?missing <config_path>}"

ENABLED=(
  CONFIG_NET_SCHED
  CONFIG_BPF
  CONFIG_BPF_SYSCALL
  CONFIG_CGROUP_BPF
  CONFIG_NET_CLS_ACT
  CONFIG_NET_CLS_BPF
  CONFIG_NET_ACT_BPF
  CONFIG_CGROUPS
  CONFIG_WIREGUARD
  CONFIG_TUN
  CONFIG_MD
  CONFIG_BLK_DEV_DM
  CONFIG_DM_THIN_PROVISIONING
  CONFIG_DM_SNAPSHOT
  CONFIG_DM_CACHE
  CONFIG_DM_MIRROR
  CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES
)

DISABLED=(
  CONFIG_DAX
)

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
