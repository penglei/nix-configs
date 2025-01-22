# My personal nvim configuration

大部分配置都来源于 nvimdots，裁剪了自己不需要的插件、快捷键，增加了自己习惯的键位。

## 插件文档

### mason

mason是一个安装、管理二进制程序的包管理器，编辑器有三种关键扩展：lsp, linter, formatter 。
这些扩展通常是一些外部工具: 要么是独立的binary，要么是某种脚本语言写的程序，
对于编辑器来说，这些工具就是一个"可执行文件"。 编辑器当然不会去维护(安装、更新、卸载)
这些binary工具，它是这些工具的消费者，只要能通过命令或者路径调用这些工具即可。
这些工具可以用传统操作系统或语言生态的包管理器来维护，对于大部份工程师来说这是一个艰难的任务，
mason自己设计了一个简单的"包管理器"，它利用各种语言生态来安装这些外部工具！
除此之外，mason在安装lsp时，还会自动配置lspconfig，为neovim lsp 提供一条龙服务。

然而，这种方式给工具维护增加了一层管理，不够透明和灵活，一些工具可能还在系统其它地方使用，
我们希望让系统中的工具保持一致。对于有经验的工程师来说，两个包管理器('system' 和 mason)让事情
变得不可控，增加相当多的复杂度。我日常使用nix管理工具，因此不需要使用mason。


### conform

在 conform.lua 的配置中，因为默认开启了prefer lsp，所以可能有些lsp没有format能力却进入了only lsp 逻辑，所以可能需要明确给filetype配置formatters。
也许 (neoconf)[https://github.com/folke/neoconf.nvim] 可以提供一些帮助。


