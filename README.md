# pigeon-kernel

Minimal Linux kernel building kit for [Firecracker](https://github.com/firecracker-microvm/firecracker) micro-VMs.

> **Experimental.** This repository uses a simplified
> kernel building approach similar to
> [Fly.io](https://community.fly.io/t/kernel-tree-config-published-someplace/1013/2) and
> [Weaveworks Ignite](https://github.com/weaveworks/ignite/tree/main/images/kernel) (archived):
> vendor the [Firecracker guest config](https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest_configs)
> and its fragment configs as a base, merge our feature fragments on top, and compile.

## How it works

1. Downloads a vanilla Linux kernel source tarball
2. Merges configs using the kernel's `merge_config.sh` in order:
   - `configs/firecracker/base-$ARCH.config` — vendored FC base
   - `configs/firecracker/*.config` — vendored FC fragments (ci, pcie, vmclock)
   - `configs/pigeon/*.config` — our feature fragments (ebpf, wireguard, lvm)
3. Compiles an uncompressed `vmlinux` (x86_64) or `Image` (aarch64)

## Build

```bash
make build                 # x86_64 (default)
make build ARCH=aarch64    # aarch64
```

Outputs `build/vmlinux` or `build/Image`, and `build/config`.