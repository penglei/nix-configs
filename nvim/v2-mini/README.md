# 基于mini.nvim 的 neovim 配置


## 分类

editing: buffer内核心编辑、跳转、自动完成等
keymaps: key mapping
lang: 按语言生态进行配置的插件，可能包含针对该语言多种特殊配置
tool: 集成的更加高层视角的工具，如 selector, terminal, test, dap, fileexplorer 等等
ui: window layout ... e.g. icons, which-key, alpha, layout, window


## 功能完成进度

* [x] Plugin Loader
* [x] `<space>` as normal leader key, `,`  as editing-oriented leader key?
* [x] mini.pick as Picker
* [x] FileExplorer (to manage project file, e.g. Copy, Delete, Paste, Rename)
* [x] StatusBar (show buffer information, edit status)
* [x] BufferBar
* [x] Theme
* [x] Syntax highlighter(tree-sitter)
* [x] lsp
* [x] motion
   * [x] hop:no, leap:yes, mini.jump2d: no
   * [x] go to line end (`gl`)
   * [x] go to file last line (`ge`)
   * [ ] nmap `g<numbers>g` to `<numbers>G`
   * [ ] **Mark the postion before entering visual in any way**
     do following map, we can go back after exiting visual mode by pressing `'v`.
     `:lua vim.keymap.set('n', 'v', 'mvv', { noremap = true })`
   * [ ] jump to function argument from bunction body (it's difficult)

     The match-up plugin can partially solve this problem.


* [ ] editing (surround, pairs, text object selection)
    * [x] code actions (tiny code actions)
    * [x] clean searching (set nohl)
    * [ ] snippets
    * [x] swap `p` and `P`(pasting without overwrite default register) in visual mode x
        the bahaviour 'pasting with overwrite default register' is designed for exchange text!
    * [x] surround action after selection. (mini surround)
    * [x] tree-sitter range selection
    * [x] treesitter syntax motion
    * [x] completion with `<Tab>` selecting
    * [-] AI
        * https://github.com/Jacob411/Ollama-Copilot
        * https://github.com/yetone/avante.nvim
    * [x] toggle comment
        * [x] ts_context_commentstring (same file with different commentstring)
    * [ ] mini.surround doens't support visual mode from mouse click
    * [-] `va{` in mini.ai implementation, sometimes it doesn't work, but i can't reproduce it.
    * [x] delete in seletion mode don't override default register by `<S-BS>`
    * [ ] selection comment block textobject

* [x] `Y` yank to system clipboard in visual mode

* [ ] ui
    * [x] terminal window border (→ switch to toggleterm fixed)
    * [ ] smart `<leader>d` to show diagnostic (if inline exist, show inline, else show buffer)
    * [ ] ~~highlight MiniSurround~~

* [ ] tool
    * dap debugger
    * [x] Neotest
    * [x] Pick: grep word under the cursor
        * [x] grep_live picker
    * [ ] asynchronous lint engine
    * [?] [**neoorg**](https://github.com/nvim-neorg/neorg)
    * [ ] [**neogit**](https://github.com/NeogitOrg/neogit)

* [x] lang
    * [x] ~~lua_lsp search path~~
    * [x] buffer上绑定按键对一些FileType没有生效(如bzl)

* [x] bugs
    * [x] 禁用visual-surround， 影响了 clipboard 寄存器的选择
    * [x] mini.comments中，`,/` 和 `,//` 有冲突，需全部配置成相同的key

## plugins

* https://github.com/nvim-treesitter/nvim-treesitter-textobjects
* https://git.sr.ht/~whynothugo/lsp_lines.nvim
* https://github.com/folke/lazydev.nvim
* https://github.com/natecraddock/workspaces.nvim
* https://github.com/mfussenegger/nvim-lint

### markdown

* https://github.com/iwe-org/iwe
* https://github.com/artempyanykh/marksman

## Key Design Thoughts

文本处理是在一个二维平面上对行列结构文本进行操作的过程。"行列" 只是文本呈现视图，它们承载着文本，
文本自身还含有更加复杂的结构信息，如词语、句子、段落、章节。对于编程语言，其自身的结构信息更加复杂。
从编辑角度看，行列视图、文本结构都只是表现形式，文本内容的内涵才是文本想表达的信息。
对文本进行处理，根本上为了让内涵信息在文本结构上正确表达。

文本包含如此复杂的信息，我们通常无法一次性地从头到位"写"出所有文本。更一般的操作是写出一些文本，
然后在此基础上进行改正，如添加、删除、替换内容，调整顺序等操作。这要求文本编辑必须有三个基本能力：

1. 移动(motion)：可以定位到文本中任何位置，再进行操作。
2. 选择(selection)：可以选择一些文本，然后对它们进行操作。
3. 动作(action)：添加、删除、替换。

文本操作可以是非线性的，可以假设同时在多个位置进行操作，同时选择多个范围，同时执行动作等等。
但我们人类大脑、眼睛、手的组合，大多数时候更习惯线性处理，我们在心理潜意识上通常会记住"事情进行到哪里了"、
"刚刚我们做了什么" 等这样的上下文信息，用于保持思维的连贯性，维持推理。因此，编辑器通常会提供一个焦点，
用来辅助我们减轻记忆负担。在文本编辑中，这个编辑焦点也是下一个动作执行的开始位置。

这三个基本能力是正交的，它们可以两两实现。例如，1和2的组合可以实现选择当前焦点到

> [!Tip]
> 基于鼠标辅助的文本编辑过程中，一些相对简单的移动和选择能直观地实现。但它们却无法方便地与动作进行组合，
> 这限制了对文本的编辑能力。而对于更加复杂的长上下文，如跨文件操作等，鼠标则显得很鸡肋。


对于文本处理，我们可以在三个层面来处理：

1. 单字、词语，标点符号等基本文本单元。

   这些基本单元是组成高级结构的基础，它们编辑过程中操作"最小的"粒度，操作频率高。
   对它们进行新增、删除、修改的操作应该尽量简单。这些基本单元粒度小，对于修改和删除操作，我们
   通常不会思考范围，而是直接应用操作(修改、删除)。

2. 句子、段落、章节，语法块等结构性文本范围上进行操作

   相比基本文本单元，很多时候要一个段落，一个结构地调整代码。这时候，选择再执行是更加可靠的方案。
   我们不能将1中"操作先于范围"的风格引入大范围的结构性文本操作，尤其是在视窗无法承载一个结构范围
   时，我们需要先选择来确认我们的操作范围是预期内的。

3. 内涵

   根据先表达的内容语义来进行操作。

   例如，根据linter或编译器给出的提示，选择自动优化或修正一段代码。
   再比如，利用生成式AI，给它下发一个指令 (e.g. "优化这个方法的注释")，完成优化。

> [!Warning]
> 有时候，句子、语法块和基本文本单元的边界是模糊的，这时候我们可能会采用level 1的方式来操作，也可能采用level 2的方式来操作。
> 建议在超过一行的时候，都采用level 2的方式进行操作。

有了前面的分析，对快捷键的设计分配便可按照基本能力和操作级别来分类，
1,2,3操作级别的频率从高到低分配按键序列，不常用的功能则可以全部用命令方式来实现。

neovim对结构性文本的处理有一个通用的抽象，叫作`textobject`。


### tips

* neovim treesitter 适配了默认的gc textobjects。see `:help gc`

  > [!NOTE] gc
  >  Text object for the largest contiguous block of
  >  non-blank commented lines around the cursor (e.g.
  >  `gcgc` uncomments a comment block; `dgc` deletes it).
  >  Works only in Operator-pending mode.


<!--
sss
aaa
-->

#### more vim configurations

* https://github.com/nshen/InsisVim
