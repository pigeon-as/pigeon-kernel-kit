#!/bin/bash
set -euo pipefail

FIRECRACKER_VERSION="${1:-v1.14.1}"
KERNEL_VERSION="${2:-6.1}"

download() {
  curl -fsSL \
    "https://raw.githubusercontent.com/firecracker-microvm/firecracker/${FIRECRACKER_VERSION}/resources/guest_configs/microvm-kernel-ci-${1}-${KERNEL_VERSION}.config" \
    --output-dir configs -O
}

main() {
  for arch in x86_64 aarch64; do
    download "${arch}"
  done
}

main
