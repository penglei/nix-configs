# my nixos/home-manager flake configurations 

* darwin: home-manager only, I don't employ nix-darwin.
* aarch64, x86_64 vm(cloud and local): nixos with embeded home-manager.
* legacy linux distribution like ubuntu: home-manager only.

## home-manager tips

```
home-manager news --flake .
```

## bootstrap tips

The newly installed NixOS does not come with vim by default,
I'm not used to the nano editor. Use the following command to temporarily use vim:

```
$ nix --extra-experimental-features nix-command --extra-experimental-features flakes shell nixpkgs#vim
```

```
$ make pin-registry
$ nix shell nixpkgs#git nixpkgs#home-manager
$ home-manager switch --flake .
$ #or
$ nix run nixpkgs#home-manager switch -- --flake .

$ sudo nixos-rebuild switch --flake .#tart-vm
```

## install

### new disk installation

### in-place installation by copytoram

### lustrate installation


```
$ bash <(curl -L https://nixos.org/nix/install) --daemon
# cat <<EOF >>/etc/nix/nix.conf
experimental-features = nix-command flakes
keep-outputs = true
keep-derivations = true
max-jobs = auto
EOF
```

root 用户执行

1. 准备环境

    ```
    # e2label /dev/vda1 nixos
    # chown -R 0:0 /nix
    # touch /etc/NIXOS
    # touch /etc/NIXOS_LUSTRATE
    # echo etc/nixos | tee -a /etc/NIXOS_LUSTRATE
    etc/nixos
    # mv -v /boot /boot.bak
    renamed '/boot' -> '/boot.bak'
    ```

    磁盘打label之后可能需要重启(也许是重启systemd-udevd)才能在 `/dev/disk/by-labels/`

2. 生成system profile

    ```
    # nix profile install --profile /nix/var/nix/profiles/system github:penglei/nix-configs#nixosConfigurations.installer.config.system.build.toplevel
    ```

    多次执行命令会提醒profile中已经存在该package。使用执行如下命令进行删除：

    ```
    # nix profile remove toplevel --profile /nix/var/nix/profiles/system
    ```


    ```
    # /nix/var/nix/profiles/system/bin/switch-to-configuration boot
    # shutdown -r now
    # nix-collect-garbage
    ```

    可以 clone 仓库到本地执行profile installing

    ```
    # nix profile install --profile /nix/var/nix/profiles/system .#nixosConfigurations.installer.config.system.build.toplevel
    ```

## references

.shell expansion

* https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
* https://zsh.sourceforge.io/Doc/Release/Expansion.html
* https://zsh.sourceforge.io/Doc/Release/Expansion.html#Modifiers
* https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion
* https://stackoverflow.com/questions/3435355/remove-entry-from-array
* https://unix.stackexchange.com/questions/411304/how-do-i-check-whether-a-zsh-array-contains-a-given-value


.macOS NSUserDefaults

* https://juejin.cn/post/6844903464300969991

.macOS awesome apps

* https://github.com/icopy-site/awesome-cn/blob/master/docs/awesome/open-source-mac-os-apps.md


.fonts

* https://jia.je/software/2021/02/09/big-sur-m1-latex-kaiti-fonts/
* https://catcat.cc/post/2020-10-31/

.icon font

* https://www.nerdfonts.com/cheat-sheet

## yabai

```
# launchctl load -F ~/Library/LaunchAgents/org.nix-community.home.yabai.plist
# launchctl unload -F ~/Library/LaunchAgents/org.nix-community.home.yabai.plist
# launchctl kickstart -k gui/$(id -u)/org.nix-community.home.yabai
```

### rime/squirrel

based on: github.com/iDvel/rime-ice

grammer model: https://github.com/lotem/rime-octagram-data/tree/hans

log location:

* $TMPDIR/rime.squirrel.INFO
* $TMPDIR/rime.squirrel.ERROR

force deploy (nix home-manager links rime config):

```
rm -rf ~/Library/Rime/build

# Press Ctrl+Option(left)+` to re-deploy

```

*Shift+space* as switcher key: https://github.com/rime/squirrel/issues/113

*installation.yaml should be writable after upgrading squirrel.*

### launchctl

launchctl bootout gui/$UID ./org.sketchybar.plist

