## 可能出现的错误

1. 没有正确配置文件系统和内核模块

    需要使用nixos-generate-config生成配置，检查里面必要的内核模块。

    ```
    # nix shell nixpkgs#nixos-install-tools
    # nixos-generate-config
    writing /etc/nixos/hardware-configuration.nix...
    writing /etc/nixos/configuration.nix...
    For more hardware-specific settings, see https://github.com/NixOS/nixos-hardware.
    ```


1.  提示systemd-boot 不存在

    ```
    root@debian:~# /nix/var/nix/profiles/system/bin/switch-to-configuration boot
    systemd-boot not installed in ESP.
    Traceback (most recent call last):
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 435, in <module>
        main()
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 418, in main
        install_bootloader(args)
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 342, in install_bootloader
        raise Exception("could not find any previously installed systemd-boot")
    Exception: could not find any previously installed systemd-boot
    Failed to install bootloader
    ```

    这时候需要提前安装 systemd-boot，安装该组件时会拷贝相应的systemd-boot配置到 /boot/efi/EFI 中

    ```
    # apt install systemd-boot
    ```


2. 错误的profile history

    ```
    # /nix/var/nix/profiles/system/bin/switch-to-configuration boot
    failed to synthesize: failed to read /nix/store/c0dj6b3247lhr4y7vj1d54a7mfzx9iv2-profile/nixos-version: No such file or directory (os error 2)
    Traceback (most recent call last):
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 435, in <module>
        main()
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 418, in main
        install_bootloader(args)
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 365, in install_bootloader
        remove_old_entries(gens)
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 243, in remove_old_entries
        bootspec = get_bootspec(gen.profile, gen.generation)
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 124, in get_bootspec
        boot_json_str = run(
                        ^^^^
      File "/nix/store/d04m4r8vrsajbkmzx2516sbbx0b8zgqj-systemd-boot/bin/systemd-boot", line 58, in run
        return subprocess.run(cmd, check=True, text=True, stdout=stdout)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      File "/nix/store/6iq3nhgdyp8a5wzwf097zf2mn4zyqxr6-python3-3.12.5/lib/python3.12/subprocess.py", line 571, in run
        raise CalledProcessError(retcode, process.args,
    subprocess.CalledProcessError: Command '['/nix/store/s81fsw2cy7pmf72lc3agx70rmfmpii8r-bootspec-1.0.0/bin/synthesize', '--version', '1', '/nix/var/nix/profiles/system-16-link', '/dev/stdout']' returned non-zero exit status 1.
    Failed to install bootloader
    ```

    这个错误看起来是引用到了错误的system profile history，具体原因位置。使用如下命令清理之后就正常了

        # nix profile remove toplevel --profile /nix/var/nix/profiles/system
    `nix profile wipe-history --profile`


## efi boot loader 原理


升级系统时，bootloader 需要通过参数明确指定进行更新


```
❯ sudo nixos-rebuild switch --install-bootloader --flake .
building the system configuration...
Created "/boot/efi/EFI/systemd".
Created "/boot/efi/EFI/Linux".
Copied "/nix/store/p0n0m1j2lzz1kmrxk1pxq9pb4x7mlk0i-systemd-256.4/lib/systemd/boot/efi/systemd-bootaa64.efi" to "/boot/efi/EFI/systemd/systemd-bootaa64.efi".
Copied "/nix/store/p0n0m1j2lzz1kmrxk1pxq9pb4x7mlk0i-systemd-256.4/lib/systemd/boot/efi/systemd-bootaa64.efi" to "/boot/efi/EFI/BOOT/BOOTAA64.EFI".
Random seed file /boot/efi/loader/random-seed successfully refreshed (32 bytes).
Created EFI boot entry "Linux Boot Manager".
```

等价于执行如下命令

```
[root@installer:~]# bootctl --esp-path=/boot/efi install
Copied "/nix/store/p0n0m1j2lzz1kmrxk1pxq9pb4x7mlk0i-systemd-256.4/lib/systemd/boot/efi/systemd-bootaa64.efi" to "/boot/efi/EFI/systemd/systemd-bootaa64.efi".
Copied "/nix/store/p0n0m1j2lzz1kmrxk1pxq9pb4x7mlk0i-systemd-256.4/lib/systemd/boot/efi/systemd-bootaa64.efi" to "/boot/efi/EFI/BOOT/BOOTAA64.EFI".
Random seed file /boot/efi/loader/random-seed successfully refreshed (32 bytes).
Created EFI boot entry "Linux Boot Manager".

```


显示efi 启动配置


```
[root@installer:~]# bootctl | cat
systemd-boot not installed in ESP.
System:
      Firmware: UEFI 2.70 (EDK II 1.00)
 Firmware Arch: aa64
   Secure Boot: disabled (unsupported)
  TPM2 Support: no
  Measured UKI: no
  Boot into FW: not supported

Current Boot Loader:
      Product: systemd-boot 256.4
     Features: ✓ Boot counting
               ✓ Menu timeout control
               ✓ One-shot menu timeout control
               ✓ Default entry control
               ✓ One-shot entry control
               ✓ Support for XBOOTLDR partition
               ✓ Support for passing random seed to OS
               ✓ Load drop-in drivers
               ✓ Support Type #1 sort-key field
               ✓ Support @saved pseudo-entry
               ✓ Support Type #1 devicetree field
               ✓ Enroll SecureBoot keys
               ✓ Retain SHIM protocols
               ✓ Menu can be disabled
               ✓ Boot loader sets ESP information
          ESP: /dev/disk/by-partuuid/a8a9a131-25e9-42ae-9a19-f8d82350bf51
         File: └─/EFI/BOOT/BOOTAA64.EFI

Random Seed:
 System Token: set
       Exists: yes

Available Boot Loaders on ESP:
          ESP: /boot/efi (/dev/disk/by-partuuid/a8a9a131-25e9-42ae-9a19-f8d82350bf51)
         File: └─/EFI/BOOT/BOOTAA64.EFI (systemd-boot 256.4)

No boot loaders listed in EFI Variables.

Boot Loader Entries:
        $BOOT: /boot/efi (/dev/disk/by-partuuid/a8a9a131-25e9-42ae-9a19-f8d82350bf51)
        token: nixos

Default Boot Loader Entry:
         type: Boot Loader Specification Type #1 (.conf)
        title: NixOS (Generation 20 NixOS Vicuna 24.11.20240917.658e722 (Linux 6.6.51), built on 2024-10-10)
           id: nixos-generation-20.conf
       source: /boot/efi//loader/entries/nixos-generation-20.conf
     sort-key: nixos
      version: Generation 20 NixOS Vicuna 24.11.20240917.658e722 (Linux 6.6.51), built on 2024-10-10
   machine-id: 883bb43cbfd3409787756cb58d784971
        linux: /boot/efi//EFI/nixos/si4wk4sxrn110xxay6lvr0c5n5cgq0j8-linux-6.6.51-Image.efi
       initrd: /boot/efi//EFI/nixos/46d073d2vrbcyc8k69whi4zdhx7sab4s-initrd-linux-6.6.51-initrd.efi
      options: init=/nix/store/slnvcqgff4vmpk9qhk2p8yfqspf2d407-nixos-system-installer-24.11.20240917.658e722/init console=ttyS0,115200 console=tty1 loglevel=4
```

3. 禁用debian的kexec重启模式

/etc/default/kexec
```

# Defaults for kexec initscript
# sourced by /etc/init.d/kexec and /etc/init.d/kexec-load

# Load a kexec kernel (true/false)
LOAD_KEXEC=false

# Kernel and initrd image
KERNEL_IMAGE="/vmlinuz"
INITRD="/initrd.img"

# If empty, use current /proc/cmdline
APPEND=""

# Load the default kernel from grub config (true/false)
USE_GRUB_CONFIG=false
```

## systemd boot loader 源码

加载loader.conf的位置 https://github.com/systemd/systemd/blob/main/src/boot/efi/boot.c#L1593

