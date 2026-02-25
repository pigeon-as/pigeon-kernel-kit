# pigeon-kernel

Minimal Linux kernel building kit for [Firecracker](https://github.com/firecracker-microvm/firecracker) micro-VMs.

> **Experimental.** This repository uses a simplified
> kernel building approach similar to
> [Fly.io](https://community.fly.io/t/kernel-tree-config-published-someplace/1013/2) and
> [Weaveworks Ignite](https://github.com/weaveworks/ignite/tree/main/images/kernel) (archived):
> vendor the [Firecracker guest config](https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest_configs)
> as a base, merge a small overlay on top, and compile.
> It may later move to a full standalone config like
> [Kata Containers](https://github.com/kata-containers/kata-containers/tree/main/tools/packaging/kernel)
> or [Bottlerocket](https://github.com/bottlerocket-os/bottlerocket-kernel-kit), we don't know.

## How it works

1. Downloads a vanilla Linux kernel source tarball
2. Merges the vendored [Firecracker guest kernel config](https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest_configs) with a small overlay (`configs/overlay.config`) using the kernel's `merge_config.sh`
3. Compiles an uncompressed `vmlinux` (x86_64) or `Image` (aarch64)

## Build

```bash
make build                 # x86_64 (default)
make build ARCH=aarch64    # aarch64
```

Outputs `build/vmlinux` or `build/Image`, and `build/config`.