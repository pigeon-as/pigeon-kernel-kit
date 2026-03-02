#!/bin/bash
# Boot the built kernel in Firecracker and verify it reaches userspace.
# Assumes: firecracker installed, run as root.
set -euo pipefail

KERNEL="${1:-build/vmlinux}"
SOCKET="/tmp/pigeon-kernel-e2e.sock"
CONSOLE="/tmp/pigeon-kernel-e2e.console"
ROOTFS="/tmp/pigeon-kernel-e2e.ext4"
INIT_BIN="/tmp/pigeon-kernel-e2e.init"
MARKER="PIGEON_KERNEL_OK"

cleanup() {
  rm -f "$SOCKET" "$CONSOLE" "$ROOTFS" "$INIT_BIN"
}

build_init() {
  gcc -static -o "$INIT_BIN" scripts/init.c \
    || { echo "FATAL: gcc -static failed (apt install build-essential)" >&2; exit 1; }
}

rootfs() {
  dd if=/dev/zero of="$ROOTFS" bs=1M count=32 2>/dev/null
  mkfs.ext4 -qF "$ROOTFS"
  local mnt
  mnt=$(mktemp -d)
  mount "$ROOTFS" "$mnt"
  mkdir -p "$mnt"/{sbin,dev}
  cp "$INIT_BIN" "$mnt/sbin/init"
  chmod +x "$mnt/sbin/init"
  umount "$mnt"
  rmdir "$mnt"
}

http_sock() {
  curl -s --unix-socket "$SOCKET" -X PUT "http://localhost/$1" -d "$2"
}

boot() {
  rm -f "$SOCKET"
  firecracker --api-sock "$SOCKET" > "$CONSOLE" 2>&1 &
  FC_PID=$!
  sleep 0.2

  http_sock "boot-source" \
    "{\"kernel_image_path\":\"$(realpath "$KERNEL")\",\"boot_args\":\"console=ttyS0 reboot=k panic=1 pci=off\"}"
  http_sock "drives/root" \
    "{\"drive_id\":\"root\",\"path_on_host\":\"$ROOTFS\",\"is_root_device\":true,\"is_read_only\":false}"
  http_sock "machine-config" \
    '{"vcpu_count":1,"mem_size_mib":128}'
  http_sock "actions" \
    '{"action_type":"InstanceStart"}'

  wait "$FC_PID" 2>/dev/null || true
}

verify() {
  if grep -q "$MARKER" "$CONSOLE"; then
    echo "PASS: kernel booted and reached userspace"
  else
    echo "FAIL: marker not found in console output" >&2
    cat "$CONSOLE" >&2
    exit 1
  fi
}

main() {
  trap cleanup EXIT
  build_init
  rootfs
  boot
  verify
}

main
