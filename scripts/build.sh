#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-6.1.155}"
ARCH="${ARCH:-x86_64}"

arch() {
  case "${ARCH}" in
    x86_64)  echo "x86" ;;
    aarch64) echo "arm64" ;;
  esac
}

cross_compile() {
  case "${ARCH}" in
    aarch64) echo "aarch64-linux-gnu-" ;;
    *)       echo "" ;;
  esac
}

image() {
  case "${ARCH}" in
    x86_64)  echo "vmlinux" ;;
    aarch64) echo "arch/arm64/boot/Image" ;;
  esac
}

download() {
  curl -fsSL "https://cdn.kernel.org/pub/linux/kernel/v${VERSION%%.*}.x/linux-${VERSION}.tar.xz" | tar -C build -xJf -
}

build() {
  # Merge order: FC base → FC fragments → pigeon fragments.
  # Later values override earlier ones. Globs expand alphabetically.
  bash "build/linux-${VERSION}/scripts/kconfig/merge_config.sh" -m -O build \
    "configs/firecracker/base-${ARCH}.config" \
    configs/firecracker/*.config \
    configs/pigeon/*.config
  make -C "build/linux-${VERSION}" O="$(pwd)/build" ARCH="$(arch)" CROSS_COMPILE="$(cross_compile)" olddefconfig
  make -C "build/linux-${VERSION}" O="$(pwd)/build" ARCH="$(arch)" CROSS_COMPILE="$(cross_compile)" -j"$(nproc)" "$(basename "$(image)")"
}

dist() {
  rm -rf dist
  mkdir -p dist
  cp "build/$(image)" build/.config dist/
}

main() {
  mkdir -p build
  download
  build
  dist
}

main
