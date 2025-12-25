# Linux Lua Userspace

This is an exploration similar to [Ultimate Linux](https://github.com/popovicu/ultimate-linux/) where the userspace is written in JavaScript. Please check out that mini repo for context on how I started doing these explorations.

## Build instructions

**This project as it is assumes you have `musl-gcc` installed at `/usr/local/musl/bin/musl-gcc`.** If you want to change this behavior, go ahead and change the files under the `toolchain` directory.

The goal is to build a statically linked binary that can run on top of a bare Linux kernel and provide a minimal interactive shell. Additionally, the build process should be as easy as possible. Therefore, to build the `initramfs` that can be booted directly by QEMU:

```bash
bazel build --platforms=//platforms:x86_64_linux_musl //userspace:initramfs
```

This will dynamically download Lua, create relevant libraries out of that source, compile userspace Lua to bytecode, integrate it into C via generated header (byte constants), build the C binary, statically link it and finally package it as a `cpio` image.

Now to run the sytem:

```bash
qemu-system-x86_64 -m 4G -kernel /tmp/linux/linux-6.17.12/arch/x86/boot/bzImage -initrd bazel-bin/userspace/initramfs.cpio -nographic --enable-kvm -smp 8 -append "console=ttyS0 rdinit=/init"
```

After the QEMU/Linux boot messages, you should see something like this:

```
...
[    0.846413] x86/mm: Checking user space page tables
[    0.880426] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[    0.881517] Run /init as init process
--- ULTIMATE LINUX SHELL (Lua Edition) ---
Commands: ls, cd, cat, mkdir, mount, umount, pwd, help, exit
[/] # mkdir /proc
[/] # mount proc /proc proc
Mount proc -> /proc: Success
[/] # cat /proc/cmdline
console=ttyS0 rdinit=/init
[/] # cat /proc/1/cmdline
/init
[/] # cat /proc/1/environ
HOME=/TERM=linux
[/] #
```