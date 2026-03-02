/*
 * Minimal init for pigeon-kernel e2e test.
 * Compiled statically, placed at /sbin/init in a throwaway rootfs.
 * Prints a marker string and reboots — that's it.
 */
#include <stdio.h>
#include <unistd.h>
#include <sys/reboot.h>
#include <linux/reboot.h>

int main(void) {
    puts("PIGEON_KERNEL_OK");
    sync();
    reboot(LINUX_REBOOT_CMD_RESTART);
    _exit(0);
}
