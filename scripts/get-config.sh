#!/bin/bash
set -euo pipefail

FIRECRACKER_VERSION="${FIRECRACKER_VERSION:?set FIRECRACKER_VERSION}"
KERNEL_VERSION="${KERNEL_VERSION:?set KERNEL_VERSION}"

BASE_URL="https://raw.githubusercontent.com/firecracker-microvm/firecracker/${FIRECRACKER_VERSION}/resources/guest_configs"
DIR="configs/firecracker"

download() {
  curl -fsSL "${BASE_URL}/${1}" -o "${DIR}/${2:-$1}"
}

main() {
  mkdir -p "$DIR"

  # base configs (renamed for brevity)
  for arch in x86_64 aarch64; do
    download "microvm-kernel-ci-${arch}-${KERNEL_VERSION}.config" "base-${arch}.config"
  done

  # fragment configs
  for config in ci.config pcie.config vmclock.config; do
    download "${config}"
  done
}

main
